{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
in
{
  options.xeta.terminal.emulator = {
    enable = mkEnableOption "Terminal emulator configuration";
  };

  config = {
    environment.systemPackages = with pkgs; [
      # foot
      kitty
      # alacritty
    ];
  };
}
