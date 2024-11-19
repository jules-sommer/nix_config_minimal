{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    ;
  cfg = config.xeta.terminal.emulator.alacritty;
in
{
  options.xeta.terminal.emulator.alacritty = {
    enable = mkEnableOption "Alacritty configuration.";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = pkgs.alacritty;
      settings = {
        general = {
          shell = lib.getBin pkgs.nushell;
          args = [ "-l" ];
        };
        window = {
          decorations = "None";
          opacity = 0.65;
          dynamic_padding = true;
          position = "None";
          blur = true;
          padding = {
            x = 8;
            y = 8;
          };
        };

        font = {
          size = 10;
          builtin_box_drawing = true;

          normal = {
            family = "JetBrains Mono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "JetBrains Mono Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "JetBrains Mono Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "JetBrains Mono Nerd Font";
            style = "Bold Italic";
          };
        };

        scrolling = {
          history = 10000;
          multiplier = 6;
        };

        selection = {
          save_to_clipboard = true;
        };

        # Catppuccin Mocha
        # "https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-mocha.toml"
        colors = {
          primary = {
            background = "#1E1E2E";
            foreground = "#CDD6F4";
            dim_foreground = "#CDD6F4";
            bright_foreground = "#CDD6F4";
          };
          cursor = {
            text = "#1E1E2E";
            cursor = "#F5E0DC";
          };
          vi_mode_cursor = {
            text = "#1E1E2E";
            cursor = "#B4BEFE";
          };
          search = {
            matches = {
              foreground = "#1E1E2E";
              background = "#A6ADC8";
            };
            focused_match = {
              foreground = "#1E1E2E";
              background = "#A6E3A1";
            };
          };
          footer_bar = {
            foreground = "#1E1E2E";
            background = "#A6ADC8";
          };
          hints = {
            start = {
              foreground = "#1E1E2E";
              background = "#F9E2AF";
            };
            end = {
              foreground = "#1E1E2E";
              background = "#A6ADC8";
            };
          };
          selection = {
            text = "#1E1E2E";
            background = "#F5E0DC";
          };
          normal = {
            black = "#45475A";
            red = "#F38BA8";
            green = "#A6E3A1";
            yellow = "#F9E2AF";
            blue = "#89B4FA";
            magenta = "#F5C2E7";
            cyan = "#94E2D5";
            white = "#BAC2DE";
          };
          bright = {
            black = "#585B70";
            red = "#F38BA8";
            green = "#A6E3A1";
            yellow = "#F9E2AF";
            blue = "#89B4FA";
            magenta = "#F5C2E7";
            cyan = "#94E2D5";
            white = "#A6ADC8";
          };
          dim = {
            black = "#45475A";
            red = "#F38BA8";
            green = "#A6E3A1";
            yellow = "#F9E2AF";
            blue = "#89B4FA";
            magenta = "#F5C2E7";
            cyan = "#94E2D5";
            white = "#BAC2DE";
          };
          indexed_colors = [
            {
              index = 16;
              color = "#FAB387";
            }
            {
              index = 17;
              color = "#F5E0DC";
            }
          ];
        };
      };
    };
  };
}
