{
  lib,
  pkgs,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib)
    mkOpt
    types
    mkEnableOption
    mkIf
    ;
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
      cursor.size = 24;
      opacity.terminal = 0.8;
      fonts = {
        monospace = {
          package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.montserrat;
          name = "Montserrat";
        };
        serif = {
          package = pkgs.montserrat;
          name = "Montserrat";
        };
        sizes = {
          applications = 12;
          terminal = 15;
          desktop = 11;
          popups = 12;
        };
      };
      # fonts = {
      #   serif = {
      #     package = pkgs.dejavu_fonts;
      #     name = "DejaVu Serif";
      #   };
      #   sansSerif = {
      #     package = pkgs.dejavu_fonts;
      #     name = "DejaVu Sans";
      #   };
      #   monospace = {
      #     package = pkgs.jetbrains-mono;
      #     name = "Jetbrains Mono";
      #   };
      #   emoji = {
      #     package = pkgs.noto-fonts-emoji;
      #     name = "Noto Color Emoji";
      #   };
      # };
    };
  };
}
