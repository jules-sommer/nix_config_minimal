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
      tor = {
        enable = mkEnableOption "Enable Tor";
      };
    };
  };

  config = mkIf cfg.tor.enable {
    environment.systemPackages = with pkgs; [
      tor
      tor-browser
    ];

    services.tor = {
      inherit (cfg.tor) enable;
    };
  };
}
