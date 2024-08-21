{
  lib,
  config,
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

  config = mkIf cfg.enable {
    services.i2p = {
      inherit (cfg.i2p) enable;
    };
    services.i2pd = {
      inherit (cfg.i2pd) enable;
    };
  };
}
