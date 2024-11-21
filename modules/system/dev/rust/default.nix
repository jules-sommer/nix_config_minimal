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
  cfg = config.xeta.development.rust;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))
    ];
  };
}
