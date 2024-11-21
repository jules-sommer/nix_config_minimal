{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    ;
  cfg = config.xeta.services.hydroxide;
in
{
  options.xeta.services.hydroxide = {
    enable = mkEnableOption "Enable Proton Mail Bridge configuration via Hydroxide.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ hydroxide ];
    systemd.user.services = {
      hydroxide = {
        name = "hydroxide.service";
        path = [ pkgs.hydroxide ];
        description = "Proton Mail Bridge via Hydroxide in Golang.";
        script = lib.concatStringsSep "\n" [
          "#!${lib.getBin pkgs.nushell}"
          "hydroxide serve"
        ];

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        wantedBy = [ "default.target" ];
      };
    };
  };
}
