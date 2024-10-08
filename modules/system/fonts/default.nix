{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.xeta.fonts;
in
{
  options.xeta.fonts = {
    enable = lib.mkEnableOption "Enable system fonts";
  };

  config = mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;

      packages = with pkgs; [
        ubuntu_font_family
        jetbrains-mono
        fira-code
        roboto
        roboto-mono
        roboto-serif
        font-awesome
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        (nerdfonts.override {
          fonts = [
            "Hack"
            "JetBrainsMono"
            "FiraCode"
          ];
        })
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ "Ubuntu" ];
          sansSerif = [ "Ubuntu" ];
          monospace = [ "JetBrains Mono" ];
        };
      };
    };
  };
}
