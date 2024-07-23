{
  lib,
  pkgs,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.theming;
in
{
  options.xeta.theming = {
    stylix = {
      enable = mkEnableOption "Enable theming via stylix.";
    };
  };

  config = mkIf cfg.stylix.enable {
    stylix = {
      enable = cfg.stylix.enable;
      image = ./assets/zoe-love-4k.png;
      polarity = "dark";

      fonts = {
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        monospace = {
          package = pkgs.jetbrains-mono;
          name = "Jetbrains Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
