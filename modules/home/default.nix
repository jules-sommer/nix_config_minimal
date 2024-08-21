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
    ./apps
    ./pkgs
    ./utils
    ./desktop
    ./terminal
  ];

  config = {
    assertions = [
      {
        assertion = lib ? mkOpt && lib ? mkIf;
        message = "Could not find flake's lib functions, is the `lib` module argument being sourced from nixpkgs.lib and ./{FLAKE_ROOT}/lib and then provided to all modules via module.args sr extraSpecialArgs";
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
      vencord
      vesktop
      dorion
      cordless
      # ungoogled-chromium
      chromium
      vivaldi
      libgen-cli
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
