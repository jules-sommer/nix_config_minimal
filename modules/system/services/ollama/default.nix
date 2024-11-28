{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
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
      inherit (cfg) enable;
      acceleration = "rocm";
    };
  };
}
