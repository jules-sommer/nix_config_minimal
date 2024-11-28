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
    ;
  cfg = config.xeta.apps;
in
{
  options.xeta.apps = {
    okular = {
      enable = mkEnableOption "Enable Okular PDF editor.";
    };
    masterpdf = {
      enable = mkEnableOption "Enable Master PDF Editor, supports XFA forms.";
    };
    libreoffice = {
      enable = mkEnableOption "Enable LibreOffice.";
    };
  };

  config = mkIf (cfg.okular.enable || cfg.libreoffice.enable) {
    environment.systemPackages = with pkgs; [
      (mkIf cfg.okular.enable okular)
      (mkIf cfg.libreoffice.enable libreoffice)
      (mkIf cfg.masterpdf.enable masterpdfeditor)
    ];
  };
}
