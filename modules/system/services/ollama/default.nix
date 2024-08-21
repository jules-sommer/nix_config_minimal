{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOpt
    mkEnableOption
    types
    ;
  cfg = config.xeta.services.ollama;
in
{
  options.xeta.services.ollama = {
    enable = mkEnableOption "Enable Ollama (local LLM server CLI) configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ollama-rocm
      alpaca
    ];

    services.ollama = {
      enable = cfg.enable;
      acceleration = "rocm";
    };
  };
}
