rec {
  mkJekyll = { pkgs, config ? {}, ...}: 
    let
      options = pkgs.lib.evalModules {
        modules = [{ imports = [ ./module.nix ]; } config];
        specialArgs = { inherit pkgs; };
      };
      cfg = options.config;
    in cfg.ruby-packages;
}
