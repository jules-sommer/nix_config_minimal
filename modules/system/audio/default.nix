{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOpt
    types
    ;
  cfg = config.xeta.audio;
in
{
  options.xeta.audio = {
    pipewire = {
      enable = mkEnableOption "Enable pipewire audio support.";
    };
    patchbay = {
      enable = mkEnableOption "Enable patchbay application for routing pipewire audio.";
      package = mkOpt types.package "Package to use as the default patchbay for pipewire.";
    };
  };

  config = mkIf cfg.pipewire.enable {
    environment.systemPackages = with pkgs; [
      friture
      sonic-visualiser

      pavucontrol
      helvum
    ];

    # disable pulseaudio if pipewire is enabled
    hardware.pulseaudio.enable = !cfg.pipewire.enable;
    security.rtkit.enable = cfg.pipewire.enable;
    services.pipewire = {
      inherit (cfg.pipewire) enable;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
