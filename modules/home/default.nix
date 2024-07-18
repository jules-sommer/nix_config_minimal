{ config, lib, ... }: {
  imports = [
    ./apps/tty/default.nix  
    ./pkgs/default.nix
  ];

  config = {
    home.username = "jules";
    home.homeDirectory = lib.mkDefault "/home/jules/";
    home.stateVersion = "24.05";
  };
}
