{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.development.go;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      go
      gopls
    ];
  };
}
