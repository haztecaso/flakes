rec {
  mkGemfile = { pkgs, gems }: pkgs.writeText "Gemfile" ''
    source "https://rubygems.org"
    ${pkgs.lib.concatMapStringsSep "\n" (pkg: ''gem "${pkg}"'') gems}
  '';
  bundleLock = { pkgs, gemfile }: pkgs.stdenv.mkShellScriptBin "lock" {
    name = "Gemfile.lock";
    src = gemfile;
    buildInputs = with pkgs; [ bundler ]; 
    unpackPhase = "cp $src Gemfile";
    buildPhase = ''
      ping rubygems.org
      ping -c 1 rubygems.org &> /dev/null \
        && bundle lock || { echo "ERROR: Cannot ping rubygems.org"; exit 1; }
      bundle lock
    '';
    installPhase = ''
      cp Gemfile.lock $out
    '';
  };

  mkJekyll = { pkgs, config ? {}, ...}: 
    let
      jekyllOptions = pkgs.lib.evalModules {
        modules = [{ imports = [ ./module.nix ]; } config ];
        specialArgs = { inherit pkgs; };
      };
      cfg = jekyllOptions.config;
      gemfile = mkGemfile { inherit pkgs; gems = cfg.gems ; };
    in mkLockfile { inherit pkgs gemfile; };
    # in rec {
    #   name = cfg.name;
    #   gemfile = mkGemfile { inherit pkgs; gems = cfg.gems ; };
    #   lockfile = mkLockfile { inherit pkgs gemfile; };
    # };
    # in with pkgs; bundlerEnv {
    #   name = cfg.name;
    #   ruby = pkgs.ruby;
    #   gemfile = ;
    #   lockfile = ;
    #   gemset = ;
    # };
}
