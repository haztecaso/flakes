{
  description = "jekyll configurations for different environments.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
  let
      lib = import ./lib.nix;
  in
    {
      overlay = final: prev: {
        mkJekyll = lib.mkJekyll; 
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
      in rec {
        packages = {
          jekyllFull = pkgs.jekyllFull;
          mkJekyll = pkgs.mkJekyll;
        };

        defaultPackage = packages.jekyllFull;

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ packages.jekyllFull bundler ruby nodejs ];
        };
      });
}
