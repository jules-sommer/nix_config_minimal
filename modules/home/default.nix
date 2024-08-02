{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) enabled;
in
{
  imports = [
    ./apps/default.nix
    ./pkgs/default.nix
    ./utils/default.nix
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

    home.username = "jules";
    home.homeDirectory = "/home/jules";
    home.stateVersion = "24.05";
  };
}
