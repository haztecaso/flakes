{
  description = "jekyll configurations for different environments.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
  let
    lib = import ./lib.nix;
    mkJekyll = lib.mkJekyll;
  in
    {
      overlay = final: prev: {
        mkJekyll = config: mkJekyll { inherit config; pkgs = final; }; 
        # jekyllFull = mkJekyll {
        #     pkgs = final;
        #     config = {
        #       gems = [
        #         "jekyll-contentblocks"
        #         "jekyll-image-size"
        #         "jekyll-minifier"
        #         "jekyll-seo-tag"
        #         "jekyll-sitemap"
        #         "ruby-thumbor"
        #       ];
        #     };
        # };
        jekyllFull = final.callPackage ({ bundlerEnv, ruby }: bundlerEnv {
          name = "jekyllFull";
          inherit ruby;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = ./gemset.nix;
        }) {};
      };
    } // utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
        mkAppScript = name: script: {
          type = "app";
          program = "${pkgs.writeShellScriptBin name script}/bin/${name}";
        };
      in rec {
        packages = {
          # mkJekyll = pkgs.mkJekyll;
          jekyllFull = pkgs.jekyllFull;
        };

        defaultPackage = packages.jekyllFull;

        apps = {
          lock = mkAppScript "lock" ''
              ${pkgs.bundler}/bin/bundle lock
              ${pkgs.bundix}/bin/bundix
          '';
        };

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ packages.jekyllFull bundler ruby nodejs ];
        };
      });
}
