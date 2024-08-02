{ config, pkgs, lib, ... }: {
  imports = [
    ./apps/default.nix
    ./pkgs/default.nix
  ];

  config = {
    assertions = [
      {
        assertion = lib ? mkOpt && lib ? mkIf;
        message = "lib.mkOpt and lib.mkIf are not available";
      }
    ];
    xeta = {
      terminal.emulator = {
        enable = true;
        package = pkgs.kitty;
      };
    };

    xdg.configHome = lib.mkForce "/home/jules/070_dotfiles/000_home-manager";
    home.username = "jules";
    home.homeDirectory = "/home/jules";
    home.stateVersion = "24.05";
  };
}
