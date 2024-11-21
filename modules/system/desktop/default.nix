{ lib, config, ... }:
let
  inherit (lib) mkEnableOption;
  cfg = config.xeta.desktop.xserver;
in
{
  imports = [
    ./hyprland
    ./plasma6
    ./river
  ];

  options.xeta.desktop.xserver = {
    enable = mkEnableOption "Enable xserver.";
  };

  config = {
    # enable xserver for any desktop env that needs it
    qt = {
      enable = true;
      style = "breeze";
      platformTheme = "kde";
    };
    services = {
      xserver = {
        inherit (cfg) enable;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;
        autorun = true;
        xkb = {
          layout = "us";
          options = "eurosign:e,caps:escape";
        };
      };
    };
  };
}
