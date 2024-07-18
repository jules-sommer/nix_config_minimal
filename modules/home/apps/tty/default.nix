{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOpt mkIf types;

  cfg = config.xeta.apps.tty;
  theme = lib.xeta.getThemeBase24 "tokyo-night-dark";
in
{
  options.xeta.apps.tty = {
    default = mkOpt (types.nullOr (
      types.enum [
        pkgs.alacritty
        pkgs.kitty
      ]
    )) null "The default terminal emulator to use";
  };

  config = mkIf (cfg.default != null) {
    assertions = [
      {
        assertion =
          (cfg.default != null)
          &&
            (lib.elem (cfg.default) [
              pkgs.alacritty
              pkgs.kitty
            ]) != null;
        message = "You must set a default terminal emulator to use this flake, and it must be one of the following: alacritty, kitty @ config.xeta.tty.default";
      }
    ];
    programs = {
      kitty = {
        enable = true;
        package = pkgs.kitty;
        font = {
         name = "JetBrains Mono Nerd Font";
          size = 12;
        };
        settings = {
          cursor = theme.colors.base0FA;
          cursor_text_color = theme.colors.base06;
          scrollback_lines = 10000;
          copy_on_select = "yes";
          background_opacity = "0.5";
          background_blur = 20;
          background = theme.colors.base01;
        };
      };

      alacritty = {
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
  };
}
