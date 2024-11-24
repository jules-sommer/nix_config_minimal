{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    ;
  cfg = config.xeta.terminal.shell;
in
{
  options.xeta.terminal.shell = {
    fish = mkEnableOption "Enable fish.";
    zsh = mkEnableOption "Enable zsh.";
  };

  config = {
    programs = {
      direnv = {
        enable = true;
        loadInNixShell = true;
      };
      nix-index = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      fish = mkIf cfg.fish {
        enable = true;
        shellInit = lib.concatStringsSep "\n" [
          "set fish_greeting ''"
        ];
        shellAliases =
          {
            ls = "eza --icons --hyperlink --color";
          }
          // (mkIf config.xeta.security.doas.enable {
            sudo = "doas";
            sudoedit = "doas rnano";
          });
        shellAbbrs = {
          lst = "eza --icons=always --hyperlink --color=always --color-scale=all --color-scale-mode=gradient -TL1";
          ff = "fastfetch";
          br = "broot -hips";
          yank = "wl-copy";
          put = "wl-paste";
          sync = "rsync -avh --progress";
          mirror_sync = "rsync -avzHAX --delete --numeric-ids --info=progress2";
          cd = "z";
          ci = "zi";
          clone = "gix clone";
          gco = "git checkout";
          gc = "git commit";
          gca = "git commit -a";
        };
      };
      zsh = mkIf cfg.zsh {
        enable = true;
        syntaxHighlighting = {
          enable = true;
          highlighters = [
            "main"
            "brackets"
            "pattern"
            "cursor"
          ];
          patterns = {
            "rm -rf *" = "fg=white,bold,bg=red";
            "rm -rf" = "fg=red";
          };
        };
        zsh-autoenv.enable = true;
        shellAliases = {
          ll = "ls -la";
          ff = "fastfetch";
          br = "broot -hips";
          yank = "wl-copy";
          put = "wl-paste";
          sync = "rsync -avh --progress";
          mirror_sync = "rsync -avzHAX --delete --numeric-ids --info=progress2";
          cp = "rsync";
          cd = "z";
          ci = "zi";
          du = "dutree";
          clone = "gix clone";
          gco = "git checkout";
          gc = "git commit";
          gca = "git commit -a";
          z = "__zoxide_z";
          zi = "__zoxide_zi";
        };
      };
    };
  };
}
