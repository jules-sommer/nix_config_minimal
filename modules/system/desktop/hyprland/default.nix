{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.xeta.desktop.hyprland;
in
{
  options.xeta.desktop.hyprland = {
    enable = mkEnableOption "Enable Hyprland.";
    package = mkOpt types.package pkgs.hyprland "Package to use for hyprland.";
    xwayland = mkEnableOption "enable xwayland support for hyprland";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      wayland-protocols
      wayland-utils
      hyprutils
      hyprcursor
    ];

    programs.hyprland = {
      enable = true;
      systemd.setPath.enable = true;
      xwayland.enable = cfg.xwayland;
      # xwayland.hidpi = true;

      inherit (cfg) package;
    };
  };
}
