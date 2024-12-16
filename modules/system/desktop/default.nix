{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.xeta.desktop;
in
{
  imports = [
    ./hyprland
    ./plasma6
    ./river
  ];

  options.xeta.desktop = {
    xserver = {
      enable = mkEnableOption "Enable xserver.";
    };
    qt = {
      enable = mkEnableOption "Enable qt configuration.";
    };
  };

  config = {
    qt = mkIf cfg.qt.enable {
      inherit (cfg.qt) enable;
      style = "breeze";
      platformTheme = "kde";
    };
    services = {
      xserver = mkIf cfg.xserver.enable (mkDefault {
        inherit (cfg.xserver) enable;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;
        autorun = true;
        xkb = {
          layout = "us";
          options = "eurosign:e,caps:escape";
        };
      });
    };
  };
}
