{
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (lib) disabled enabled mkDefault;
in
{
  imports = [
    ./dev
    ./apps
    ./user
    ./audio
    ./kernel
    ./networking
    ./theming
    ./services
    ./security
    ./fonts
    ./desktop
    ./terminal
  ];

  config = {
    programs = {
      nix-ld.enable = true;
      command-not-found.enable = false;
      nix-index = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
      mtr.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

  };
}
