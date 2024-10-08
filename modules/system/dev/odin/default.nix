{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.xeta.development.odin;
in
{

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      odin
      ols
    ];
  };
}
