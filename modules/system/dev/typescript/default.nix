{
  lib,
  system,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkIf
    mkEnableOption
    ;
  cfg = config.xeta.development.typescript;

  runtimes = lib.mkMerge [
    (mkIf (builtins.elem "node" cfg.runtimes) (
      with pkgs;
      [
        node
        fnm
        nodenv
        bun
      ]
    ))
    (mkIf (builtins.elem "deno" cfg.runtimes) (with pkgs; [ deno ]))
    (mkIf (builtins.elem "bun" cfg.runtimes) (
      with pkgs;
      [
        bun
        edge-runtime
      ]
    ))
  ];
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ nodePackages_latest.typescript-language-server ];
  };
}
