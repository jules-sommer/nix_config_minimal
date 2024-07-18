{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.development.go;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nvd
      nix-du
      nixfmt-rfc-style
      nh
      nix-output-monitor
      nix-prefetch-git
    ];
  };
}
