{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
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
      inherit (cfg.stylix) enable;
      image = ./assets/city-night-neon-pink.png;
      polarity = "dark";
      cursor.size = 24;
      homeManagerIntegration = {
        autoImport = true;
        followSystem = true;
      };
      override = {
        base00 = "000000";
      };
      targets = {
        nixvim = {
          enable = true;
          transparentBackground = {
            main = true;
            signColumn = true;
          };
        };
      };
      opacity = {
        terminal = 0.75;
        popups = 0.75;
        applications = 0.9;
        desktop = 0.9;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
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
    };
  };
}
