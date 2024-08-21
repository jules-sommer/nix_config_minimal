{ lib, ... }:
with lib;
{
  options.xeta.desktop.plasma6 = {
    enable = mkEnableOption "plasma6 desktop environment";
  };
  config = {
    services = {
      displayManager.sddm.wayland.enable = true;
      desktopManager.plasma6.enable = true;
    };
  };
}
