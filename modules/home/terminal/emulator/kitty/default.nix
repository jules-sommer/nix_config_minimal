{
  lib,
  config,
  pkgs,
  theme,
  ...
}:
let
  inherit (lib)
    mkOpt
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.xeta.terminal.emulator.kitty;
in
{
  options.xeta.terminal.emulator.kitty = {
    enable = mkEnableOption "Kitty configuration.";
    package = mkOpt types.package pkgs.kitty "Package to use for Kitty configuration.";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      KITTY_CONFIG_DIRECTORY = "/home/jules/.config/kitty/";
      KITTY_ENABLE_WAYLAND = "1";
    };

    programs.kitty = lib.mkDefault {
      enable = true;
      package = pkgs.kitty;
      font = {
        name = "JetBrains Mono Nerd Font";
        size = 12;
      };
      environment = {
        KITTY_ENABLE_WAYLAND = "1";
        KITTY_CONFIG_DIRECTORY = "/home/jules/.config/kitty";
      };
      shellIntegration = {
        mode = "enabled";
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
      settings = {
        cursor = theme.colors.base0FA;
        linux_display_server = "wayland";
        cursor_text_color = theme.colors.base06;
        tab_bar_edge = "bottom";
        allow_remote_control = "yes";
        # enabled_layouts = "splits";
        tab_bar_style = "slant";
        tab_bar_margin_width = 1;
        tab_bar_margin_height = "1.0 1.0";
        transparent = true;
        scrollback_lines = 15000;
        copy_on_select = "yes";
        background_opacity = "0.8";
        background_blur = 50;
        background = "#000000";
      };
    };
  };
}
