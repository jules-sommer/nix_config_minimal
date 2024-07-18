{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) types mkOpt mkEnableOption mkIf;
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
