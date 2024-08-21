{
  lib,
  pkgs,
  config,
  inputs,
  system,
  theme,
  ...
}:
let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkOption
    mkOpt
    getPackage
    ;

  inherit (theme) colors;

  cfg = config.xeta.desktop.hyprland;
in
{
  options.xeta.desktop.hyprland = {
    enable = mkEnableOption "Enable Hyprland (@/home-manager)";
    theme = mkOpt (types.nullOr types.str) "tokyo-night-dark" "Theme to use";

    settings = {
      modifier = mkOpt (types.nullOr types.enum ([
        "CTRL"
        "ALT"
        "SUPER"
      ])) "ALT" "Modifier key to use for Hyprland keybindings.";

      keybindings = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              modifiers = mkOption {
                type = types.listOf types.str;
                default = [ ]; # Empty list means "$mod" will be used by default
                description = ''
                  List of modifier keys for the binding. If empty, "$mod" is assumed as the default modifier.
                  Explicitly specify modifiers (e.g., ["ALT"], ["$mod", "SHIFT"]) to override the default.
                '';
              };
              key = mkOption {
                type = types.str;
                description = "The key associated with the binding.";
              };
              action = mkOption {
                type = types.str;
                description = "The action to perform.";
              };
              args = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Optional arguments for the action.";
              };
            };
          }
        );
        default = [ ];
        description = "Keybindings for Hyprland.";
      };

      actions = mkOpt (types.attrsOf (
        types.submodule {
          options = {
            command = mkOpt (types.nullOr types.str) null "The command to execute for this action.";
            description = mkOpt (types.nullOr types.str) null "A description of the action.";
          };
        }
      )) { } "Default actions for Hyprland.";

      applications = mkOpt (types.attrsOf (types.submodule { })) {
        options = {
          command = mkOpt (types.nullOr types.str) null "The command to execute for this application.";
          script =
            mkOpt (types.nullOr types.path) null
              "The path of the script to execute for this application.";
          description =
            mkOpt (types.nullOr types.str) null
              "A description of the application or script and it's function.";
        };
      } "Default applications for Hyprland.";

      defaults = {
        terminal = mkOpt (types.nullOr types.str) "alacritty" "Default terminal to use for Hyprland.";
        file_manager = {
          gui = mkOpt (types.nullOr types.str) "thunar" "Default GUI file manager to use for Hyprland.";
          tui =
            mkOpt (types.nullOr types.str) "alacritty -e ranger"
              "Default TUI file manager to use for Hyprland.";
        };
        menu = mkOpt (types.nullOr types.str) "rofi -show drun" "Default menu command to use for Hyprland.";
        screenshot =
          mkOpt (types.nullOr types.str) "nu ~/_dev/nu_tools/screenshot.nu"
            "Default screenshot command to use for Hyprland.";
        clipboard_manager =
          mkOpt (types.nullOr types.str) "cliphist list | wofi --dmenu | cliphist decode | wl-copy"
            "Default clipboard manager command to use for Hyprland.";
        notifycmd =
          mkOpt (types.nullOr types.str)
            "notify-send -h string:x-canonical-private-synchronous:hypr-cfg -u low"
            "Default notification command to use for Hyprland.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      swww
      eww
      hyprpaper
      swayidle
      notify
      notify-desktop
      dunst
      clipnotify
      cliphist
      swaybg
    ];

    wayland.windowManager.hyprland =
      let
        tty = config.xeta.tty;
        terminal = if (tty.default != null) then (lib.getBin tty.default) else (lib.getBin (pkgs.kitty));
      in
      {
        enable = true;
        package = getPackage {
          inherit system;
          input = inputs.hyprland;
          name = "hyprland";
        };
        xwayland.enable = true;
        systemd.enable = true;
        settings = {
          "$mod" = "ALT";
          "$terminal" = "${terminal}";
          "$multiplexer" = "${terminal} -e zellij";
          "$files" = "${terminal} -e joshuto";
          "$screenshot" = "${screenshot}";
          "$menu" = "rofi -show drun";
          "$notify" = "notify-send -h string:x-canonical-private-synchronous:hypr-cfg -u low";

          monitor = [
            "DP-1,2560x1080@74.99,1920x0,1"
            "HDMI-A-1,1920x1080@100,0x0,1"
            # "DP-1,2560x1080@80,0x0,1"
            # "HDMI-A-1,1920x1080@60,-1080x-540,1,transform,3"
            # "DVI-D-1,1920x1080@60,2560x-540,1,transform,3"
            ",highres,auto,1"
          ];
          env = [
            "NIXOS_OZONE_WL, 1"
            "NIXPKGS_ALLOW_UNFREE, 1"

            # Theming related
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
            "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
            "QT_QPA_PLATFORMTHEME,qt5ct"
            "XCURSOR_SIZE,24"
            "XCURSOR_THEME, Bibata-Modern-Ice"
            "GRIM_DEFAULT_DIR,~/060_media/000_pictures/000_screenshots"

            "MOZ_ENABLE_WAYLAND, 1"

            "GDK_BACKEND=wayland,x11"
            "CLUTTER_BACKEND, wayland"
            "SDL_VIDEODRIVER, wayland"
            "LIBVA_DRIVER_NAME,radeonsi"
            "XDG_SESSION_TYPE,wayland"
            "XDG_CURRENT_DESKTOP, Hyprland"
            "XDG_SESSION_DESKTOP, Hyprland"
            "WLR_NO_HARDWARE_CURSORS,1"
          ];

          # █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
          # ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█

          windowrulev2 = [
            "float,class:^(bitwarden)$"

            "float,title:^(?i).*bitwarden.*$"
            "float,title:^(?i).*extension:.*$"
            "float,title:^(?i).*sign in.*$"

            "center,title:^(?i).*Bitwarden.*$"
            "center,title:^(?i).*Extension:.*$"
            "center,title:^(?i).*Sign in.*$"

            "size 60% 80%,title:^(?i).*Bitwarden.*$"
            "size 60% 80%,title:^(?i).*Extension:.*$"
            "size 60% 80%,title:^(?i).*Sign in.*$"

            "idleinhibit focus, class:^(vlc)$"
            "idleinhibit fullscreen, class:^(floorp)$"

            "float,class:^(pavucontrol)$"
            "move 10% 50,class:^(pavucontrol)$"
            "size 550 550,class:^(pavucontrol)$"
            "pin,class:^(pavucontrol)$"
          ];

          windowrule = [

          ];

          # ▄▀█ █░█ ▀█▀ █▀█    █▀▀ ▀▄▀ █▀▀ █▀▀
          # █▀█ █▄█ ░█░ █▄█    ██▄ █░█ ██▄ █▄▄

          exec-once = [
            "hyprpaper"
            "pueued -dv"
            "$POLKIT_BIN"
            "nm-applet --indicator"
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "hyprctl setcursor Bibata-Modern-Ice 24"
            "swww init"
            "waybar"
            "swaync"
            "swayidle -w timeout 720 'tuigreet --greeting \"Hello, Jules! We put xeta to sleep but she's okieee dw. :)\"' timeout 800 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'tuigreet'"
            # "swaybg - m fill - i ~/Pictures/wallpapers/zoelove.jpg" # alternative to swww for wallpaper
            # "swww img --filter Lanczos3 ~/Pictures/wallpapers/zoelove.jpg" # SINGLE monitor
            "swww img - -filter Lanczos3 ~/060_media/010_wallpapers/zoe-love-bg/center-uw.png - o DP-3"
            "swww img - -filter Lanczos3 ~/060_media/010_wallpapers/zoe-love-bg/left-vertical.png - o HDMI-A-1"
            "swww img - -filter Lanczos3 ~/060_media/010_wallpapers/zoe-love-bg/right-vertical.png - o DVI-D-1"
          ];

          # █▀ █░█ █▀█ █▀█ ▀█▀ █▀▀ █░█ ▀█▀ █▀
          # ▄█ █▀█ █▄█ █▀▄ ░█░ █▄▄ █▄█ ░█░ ▄█

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

          bind =
            [
              # F keypress
              "$mod, F, exec, floorp"
              "$mod SHIFT, F, togglefloating, "
              # C keypress
              "$mod, C, killactive, "
              # M keypress
              "$mod SHIFT, M, exit, "
              # W keypress
              "$mod, W, exec, $menu"
              "$mod SHIFT, W, exec, $terminal"

              "$mod, code:51, togglesplit" # | key (BAR/PIPE)

              "$mod, O, exec, $files"
              "CTRL SHIFT, S, exec, $screenshot"

              "$mod, D, exec, swaync-client -t"
              # Terminal and Alacritty for $mod + {T, A}
              "$mod, code:36, exec, $multiplexer" # ENTER key
              "$mod SHIFT, code:36, exec, $terminal"

              # Hycov
              "$mod, tab, hycov:toggleoverview"
              "$mod, left, hycov:movefocus,l"
              "$mod, right, hycov:movefocus,r"
              "$mod, up, hycov:movefocus,u"
              "$mod, down, hycov:movefocus,d"

              # File manager $mod + {F}
              "$mod, P, pseudo, # dwindle"
              "$mod SHIFT, SPACE, movetoworkspace,special"
              "$mod, SPACE, togglespecialworkspace"

              "$mod, left,          movefocus, l"
              "$mod, right,         movefocus, r"
              "$mod, up,            movefocus, u"
              "$mod, down,          movefocus, d"

              "$mod SHIFT, left,    swapwindow, l"
              "$mod SHIFT, right,   swapwindow, r"
              "$mod SHIFT, up,      swapwindow, u"
              "$mod SHIFT, down,    swapwindow, d"

              "$mod CTRL, left,     resizeactive, -60 0"
              "$mod CTRL, right,    resizeactive, 60 0"
              "$mod CTRL, up,       resizeactive, 0 -60"
              "$mod CTRL, down,     resizeactive, 0 60"

              "$mod SHIFT, mouse_up, workspace, e+1"
              "$mod SHIFT, mouse_down, workspace, e-1"

              "ALT,Tab,cyclenext"
              "ALT,Tab,bringactivetotop"

              ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
              ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ",XF86MonBrightnessDown,exec,brightnessctl set 5%-"
              ",XF86MonBrightnessUp,exec,brightnessctl set +5"
              ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ",XF86AudioPlay, exec, playerctl play-pause"
              ",XF86AudioPause, exec, playerctl play-pause"
              ",XF86AudioNext, exec, playerctl next"
              ",XF86AudioPrev, exec, playerctl previous"

              # clipboard manager with wofi
              "$mod SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
            ]
            ++ (
              # workspaces
              # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
              builtins.concatLists (
                builtins.genList (
                  x:
                  let
                    ws =
                      let
                        c = (x + 1) / 10;
                      in
                      builtins.toString (x + 1 - (c * 10));
                  in
                  [
                    "$mod, ${ws}, workspace, ${toString (x + 1)}"
                    "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                  ]
                ) 10
              )
            );

          # ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀
          # █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█ ▄█
          #                                        
          # ▄▀█ █▄░█ █▀▄    █▀▄ █▀▀ █▀▀ █▀█ █▀█ █▀
          # █▀█ █░▀█ █▄▀    █▄▀ ██▄ █▄▄ █▄█ █▀▄ ▄█

          animations = {
            enabled = "yes";
            bezier = [
              "wind, 0.05, 0.9, 0.1, 1.05"
              "winIn, 0.1, 1.1, 0.1, 1.1"
              "winOut, 0.3, -0.3, 0, 1"
              "liner, 1, 1, 1, 1"
            ];
            animation = [
              "windows, 1, 6, wind, slide"
              "windowsIn, 1, 6, winIn, slide"
              "windowsOut, 1, 5, winOut, slide"
              "windowsMove, 1, 5, wind, slide"
              "border, 1, 1, liner"
              "borderangle, 1, 30, liner, loop"
              "fade, 1, 10, default"
              "workspaces, 1, 5, wind"
            ];
          };

          decoration = {
            rounding = "15";
            blurls = [
              "waybar"
              "swaync-control-center"
              "swaync-notification-window"
              "swayidle-inactive-notification"
              "swayidle-idle-notification"
            ];
            layerrule = [
              "blur,waybar"
              "blur,rofi"
              "blur,dunst"
              "blur,swaybg"
              "blur,swayidle"
              "blur,pavucontrol"
              "blur,alacritty"
              "blur,kitty"
              "unset, rofi"
              "blur, rofi"
              "ignorezero, rofi"
              "blur, swaync-control-center"
              "blur, swaync-notification-window"
              "ignorezero, swaync-control-center"
              "ignorezero, swaync-notification-window"
              "ignorealpha 0.1, swaync-control-center"
              "ignorealpha 0.1, swaync-notification-window"
            ];
            drop_shadow = true;
            blur = {
              enabled = true;
              size = "8";
              passes = "3";
              new_optimizations = "on";
              ignore_opacity = "on";
            };
          };

          # █▀▄▀█ █ █▀ █▀▀ ░
          # █░▀░█ █ ▄█ █▄▄ ▄

          general = {
            "gaps_in" = 4;
            "gaps_out" = 8;
            "border_size" = 3;
            "col.active_border" = "rgba(${colors.base0C}ff) rgba(${colors.base0D}ff) rgba(${colors.base0B}ff) rgba(${colors.base0E}ff) 45deg";
            "col.inactive_border" = "rgba(${colors.base0C}40) rgba(${colors.base0D}40) rgba(${colors.base0B}40) rgba(${colors.base0E}40) 45deg";
            "layout" = "dwindle";
            "resize_on_border" = "true";
          };

          input = {
            kb_layout = "us";
            # kb_options = [ "grp:alt_shift_toggle" "caps:super" ];
            kb_options = [ "caps:swapescape" ];
            follow_mouse = 1;
            touchpad = {
              natural_scroll = false;
            };
            sensitivity = 0.7; # -1.0 - 1.0, 0 means no modification.
            accel_profile = "none";
          };

          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          master = {
            new_is_master = true;
          };

          misc = {
            vrr = 2;
            disable_hyprland_logo = true;
            render_ahead_of_time = false;
            enable_swallow = true;
            animate_manual_resizes = true;
            animate_mouse_windowdragging = true;
            close_special_on_empty = false;
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = true;
            swallow_regex = "^(Alacritty)$";
          };
        };
      };
  };
}
