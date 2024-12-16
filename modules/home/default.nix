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
        shellInit = '''';
      };
      broot = {
        enable = true;
        enableNushellIntegration = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
    };
  };
}
