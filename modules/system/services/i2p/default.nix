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
  cfg = config.xeta.services.hidden;
in
{
  options.xeta.services = {
    hidden = {
      i2p = {
        enable = mkEnableOption "Enable Proton Mail Bridge configuration via Hydroxide.";
      };
      i2pd = {
        enable = mkEnableOption "Enable Proton Mail Bridge configuration via Hydroxide.";
      };
    };
  };

  config = mkIf (cfg.i2p.enable || cfg.i2pd.enable) {
    environment.systemPackages = with pkgs; [
      i2p
      i2pd
    ];

    services.i2p = {
      inherit (cfg.i2p) enable;
    };
    services.i2pd = {
      inherit (cfg.i2pd) enable;
    };
  };
}
