{
  lib,
  inputs,
  system,
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
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      wayland-protocols
      wayland-utils
    ];

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${system}.default;
      xwayland.enable = true;
    };
  };
}
