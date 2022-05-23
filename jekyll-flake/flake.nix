{
  description = "jekyll configurations for different environments.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        mkAppScript = name: script: {
          type = "app";
          program = "${pkgs.writeShellScriptBin name script}/bin/${name}";
        };
        jekyllFull = { bundlerEnv, ruby }: bundlerEnv {
          name = "jekyllFull";
          inherit ruby;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = ./gemset.nix;
        };
        mkWeb = { jekyllFull, ruby, nodejs, stdenv }: { pname, version, src }: stdenv.mkDerivation {
          inherit pname version src;
          buildInputs = [ jekyllFull ruby nodejs ];
          buildPhase = ''
	        JEKYLL_ENV=production jekyll build
          '';
          installPhase = ''
            mkdir -p $out/www
            cp -Tr _site $out/www/
          '';
        };
        serve = { jekyllFull, ruby, nodejs }: mkAppScript "serve" ''
          export PATH="${nodejs}/bin:$PATH"
          ${jekyllFull}/bin/jekyll serve --watch --incremental --livereload
        '';
        serve-prod = { jekyllFull, ruby, nodejs }: mkAppScript "serve-prod" ''
          export PATH="${nodejs}/bin:$PATH"
          JEKYLL_ENV=production ${pkgs.jekyllFull}/bin/jekyll serve --watch --incremental --livereload
        '';
      in {
        packages = {
          jekyllFull = pkgs.callPackage jekyllFull {};
          mkWeb      = pkgs.callPackage mkWeb { jekyllFull = packages.jekyllFull; };
        };

        defaultPackage = packages.jekyllFull;

        apps.serve = mkAppScript "serve" ''
          export PATH="${nodejs}/bin:$PATH"
          jekyll serve --watch --incremental --livereload
        '';
      
        apps.serve-prod = mkAppScript "serve-prod" ''
          export PATH="${nodejs}/bin:$PATH"
          JEKYLL_ENV=production ${pkgs.jekyllFull}/bin/jekyll serve --watch --incremental --livereload
        '';

        apps.lock = mkAppScript "lock" ''
          ${pkgs.bundler}/bin/bundle lock
          ${pkgs.bundix}/bin/bundix
        '';

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ jekyllFull ruby nodejs ];
        };
      });
}
