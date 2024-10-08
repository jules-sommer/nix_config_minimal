{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    enabled
    mkOpt
    types
    ;
  cfg = config.xeta.fonts;
in
{
  options.xeta.fonts = {
    enable = lib.mkEnableOption "Enable system fonts";
    nerdfonts = mkOpt (types.listOf types.string) [ ] "Additional NerdFonts to install";
  };

  config = mkIf cfg.enable {
    # console / tty bootloader TUI fonts
    console = {
      font = "Tamsyn10x20r";
      keyMap = lib.mkDefault "us";
      useXkbConfig = true;
      packages = with pkgs; [
        tamzen
        tamsyn
        uw-ttyp0
        spleen
        dina-font
        gohufont
        terminus_font
        terminus_font_ttf
      ];
    };
    fonts = {
      fontDir = enabled;
      enableDefaultPackages = true;
      fontconfig = {
        enable = true;
        subpixel.rgba = "rgb";
        includeUserConf = true;
        antialias = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "JetBrains Mono" ];
          emoji = [ "Noto Color Emoji" ];
        };
        hinting = {
          enable = true;
          style = "full";
        };
      };
      packages = with pkgs; [
        fira-code
        fira-code-nerdfont
        jetbrains-mono
        roboto-mono
        roboto-slab
        roboto-serif
        fira-sans
        source-sans
        source-serif
        source-code-pro
        hack-font
        noto-fonts
        noto-fonts-cjk
        inter
        melete
        raleway
        nacelle
        open-dyslexic
        unscii
        spleen
        ucs-fonts
        ubuntu_font_family
        font-awesome
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        (nerdfonts.override {
          fonts = [
            "JetBrainsMono"
            "Noto"
            "RobotoMono"
            "ZedMono"
            "Ubuntu"
            "UbuntuMono"
            "NerdFontsSymbolsOnly"
            "SpaceMono"
            "UbuntuSans"
            "Hack"
            "FiraCode"
          ] ++ cfg.nerdfonts;
        })
      ];
    };
  };
}
