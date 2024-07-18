{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.development.ocaml;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ocaml
    ];
  };
}
