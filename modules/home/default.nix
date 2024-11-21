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

    xdg = {
      inherit (homeDirs) configHome;
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
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "Noto"
          "RobotoMono"
          "ZedMono"
          "Ubuntu"
          "UbuntuMono"
          "NerdFontsSymbolsOnly"
          "SpaceMono"
          "UbuntuSans"
          "Hack"
          "FiraCode"
        ];
      })
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
