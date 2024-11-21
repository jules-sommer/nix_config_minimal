{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;
  cfg = config.xeta.apps;
in
{
  options.xeta.apps = {
    calculator = {
      enable = mkEnableOption "Enable KDE calculator";
    };
  };

  config = {
    environment.systemPackages =
      with pkgs;
      (mkMerge [
        (mkIf cfg.calculator.enable [
          kdePackages.kalk
        ])
      ]);
  };
}
