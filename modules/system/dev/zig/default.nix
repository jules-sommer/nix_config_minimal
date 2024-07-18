{
  lib,
  pkgs,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.development.zig;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      zig
      zls
      vscode-extensions.ziglang.vscode-zig
    ];
  };
}
