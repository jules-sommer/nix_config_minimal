{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  homeDirs = getHomeDirs "jules";
in
{
  imports = [
    ./apps/default.nix
    ./pkgs/default.nix
    ./utils/default.nix
    ./desktop
    ./terminal
  ];

  config = {
    assertions = [
      {
        assertion = lib ? mkOpt && lib ? mkIf;
        message = "lib.mkOpt and lib.mkIf are not available";
      }
    ];

    xeta = {
      terminal = {
        enable = true;
        emulator = mkEnabledPkg pkgs.kitty;
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
      };
    };

    xdg = {
      inherit (homeDirs) configHome;
    };

    home.packages = with pkgs; [
      obsidian
      obsidian-export
      # rustdesk
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
      username = "jules";
      homeDirectory = homeDirs.home;
      stateVersion = "24.05";
    };
  };
}
