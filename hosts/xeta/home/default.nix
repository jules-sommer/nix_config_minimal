{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnabledPkg enabled disabled;
  meta = import ../meta.nix;
in
{
  config = {
    xeta = {
      terminal = {
        enable = true;
        emulator = {
          kitty = enabled;
          alacritty = enabled;
        };
        prompt = mkEnabledPkg pkgs.starship;
        shell = {
          enable = true;
          package = pkgs.nushell;
          settings = {
            zoxide = mkEnabledPkg pkgs.zoxide;
            carapace = mkEnabledPkg pkgs.carapace;
          };
        };
      };
      desktop = {
        hyprland = disabled;
        plasma6 = enabled;
        river = disabled;
      };
    };

    home.packages = with pkgs; [
      obsidian
      obsidian-export
      vencord
      vesktop
      dorion
      signalbackup-tools
      signal-cli
      signal-desktop-beta
      cordless
      inkscape-with-extensions
      chromium
      libgen-cli
    ];

    programs = {
      ripgrep = enabled;
      fzf = enabled;
      carapace = enabled;
      fd = enabled;
      direnv = {
        enable = true;
        enableNushellIntegration = true;
      };
      gpg = enabled;
      go = enabled;
      gh = {
        enable = true;
        gitCredentialHelper = enabled;
      };
      fish = {
        enable = true;
        shellInit = '''';
      };
      broot = {
        enable = true;
        enableNushellIntegration = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
    };

    home = {
      username = meta.user;
      homeDirectory = meta.home;
      stateVersion = "24.05";
    };
  };
}
