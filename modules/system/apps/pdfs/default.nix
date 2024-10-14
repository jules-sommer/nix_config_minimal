{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkBoolOpt
    types
    mkEnableOption
    mkIf
    mkMerge
    ;
  cfg = config.xeta.apps.pdf;
in
{
  options.xeta.apps.pdf = {
    okular = {
      enable = mkEnableOption "Enable Okular PDF editor.";
    };
    libreoffice = {
      enable = mkEnableOption "Enable LibreOffice.";
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      okular
      libreoffice
    ];
  };
}
