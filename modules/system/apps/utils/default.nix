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
  cfg = config.xeta.apps.utils;
in
{
  options.xeta.apps.utils = {
    calculator = {
      enable = mkEnableOption "Enable KDE/Gnome calculator apps.";
    };
  };

  config = {
    environment.systemPackages =
      with pkgs;
      (mkMerge [
        [

        ]
        (mkIf (cfg.calculator.enable) [
          gnome-calculator
          kdePackages.kalk
        ])
      ]);
  };
}
