{
  description = "jekyll configurations for different environments.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
    {
      overlay = final: prev: rec {
        jekyllFull = prev.callPackage ({ bundlerEnv, ruby }: bundlerEnv {
          name = "jekyllFull";
          inherit ruby;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = ./gemset.nix;
        }) {};
        mkWeb = {pname, version, src}: final.callPackage ({stdenv, ruby, nodejs}: stdenv.mkDerivation {
            inherit pname version src;
            buildInputs = [ jekyllFull ruby nodejs ];
            buildPhase = ''
	          JEKYLL_ENV=production jekyll build
            '';
            installPhase = ''
              mkdir -p $out/www
              cp -Tr _site $out/www/
            '';
        }) {};
      };
    } // utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
        mkAppScript = name: script: {
          type = "app";
          program = "${pkgs.writeShellScriptBin name script}/bin/${name}";
        };
      in rec {
        packages.jekyllFull = pkgs.jekyllFull;
        packages.mkWeb = pkgs.mkWeb;
        defaultPackage = packages.jekyllFull;

        apps.lock = mkAppScript "lock" ''
          ${pkgs.bundler}/bin/bundle lock
          ${pkgs.bundix}/bin/bundix
        '';

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ jekyllFull ruby nodejs ];
        };
      });
}
