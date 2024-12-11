{ lib, ... }:
with lib;
{
  options.xeta.desktop.river = {
    enable = mkEnableOption "river window manager";
  };
  config = {
    environment.systemPackages = with pkgs; [
      way-displays
      wlopm
    ];
    programs.river = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
