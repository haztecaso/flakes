{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    mach-nix.url = "mach-nix/3.4.0";
  };

  outputs = {self, nixpkgs, mach-nix }:
    let
      l = nixpkgs.lib // builtins;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: l.genAttrs supportedSystems
        (system: f system (import nixpkgs {inherit system;}));
    in
    {
      defaultPackage = forAllSystems (system: pkgs: mach-nix.lib."${system}".mkPython {
        requirements = ''
          moodle-dl
        '';
      });
      nixosModule = { config, lib, pkgs, ... }:
      let
        cfg = config.services.moodle-dl;
        i2s = lib.strings.floatToString;
        script = pkgs.writeScriptBin "moodle-dl" ''
          #!${pkgs.runtimeShell}
          FOLDER=${cfg.folder}
          cd $FOLDER || { echo '$FOLDER does not exist' ; exit 1; }
          ln -fs ${cfg.configFile} config.json
          ${pkgs.moodle-dl}/bin/moodle-dl
        '';
      in
      {
        options.services.moodle-dl = with lib; {
          enable = mkEnableOption "Enable moodle downloader service";
          frequency = mkOption {
            type = types.int;
            default = 10;
            description = "frequency of cron job in minutes";
          };
          folder = mkOption {
            type = types.str;
            example = "/var/lib/syncthing/uni-moodle/";
            description = "path of moodle-dl folder";
          };
          configFile = mkOption {
            type = types.path;
            description = "path of moodle-dl config file."; 
          };
        };
        config = lib.mkIf config.services.moodle-dl.enable {
          environment.systemPackages = with pkgs; [ moodle-dl ];
          services.cron = {
            enable = true;
            systemCronJobs = let
              freq = lib.strings.floatToString cfg.frequency;
            in [
              ''*/${freq} * * * *  root . /etc/profile; ${script}/bin/moodle-dl''
                ];
              };
            };
      };
      overlay = final: prev: {
        impo = final.callPackage (mach-nix.lib.mkPython {
          requirements = ''
            moodle-dl
          '';
        }) {};
      };
    };
}
