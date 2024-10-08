{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.xeta.development.python;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pipx
      pip
      pipenv
      python313Full
    ];
  };
}
