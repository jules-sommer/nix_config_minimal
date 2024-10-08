{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    ;
  cfg = config.xeta.development.ocaml;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ocaml
      ocamlPackages.ocaml-lsp
      ocamlPackages.utop
    ];
  };
}
