{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.xeta.services.proton-bridge;
in
{
  options.xeta.services.proton-bridge = {
    enable = mkEnableOption "Enable Proton Mail Bridge configuration.";
  };

  config = {
    services.protonmail-bridge = {
      inherit (cfg) enable;
      logLevel = "fatal";
      path = with pkgs; [
        pass
        gnome-keyring
      ];
    };
  };
}
