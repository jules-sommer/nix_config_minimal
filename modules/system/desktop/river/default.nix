{ lib, ... }:
with lib;
{
  options.xeta.desktop.river = {
    enable = mkEnableOption "river window manager";
  };
  config = {
    programs.river = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
