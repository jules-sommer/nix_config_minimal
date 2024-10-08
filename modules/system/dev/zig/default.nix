{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.xeta.development.zig;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      zig
      zls
    ];
  };
}
