{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) enabled mkEnabledPkg getHomeDirs;

  homeDirs = getHomeDirs "jules";
in
{
  imports = [
    ./apps/default.nix
    ./pkgs/default.nix
    ./utils/default.nix
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
    };

    xdg = {
      inherit (homeDirs) configHome;
    };

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
        shellInit = ''
          echo "Welcome to Fish!"
        '';
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
