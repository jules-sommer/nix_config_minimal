{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.xeta.security;

in
{
  options.xeta.security = {
    gnome-keyring = {
      enable = mkEnableOption "Enable gnome-keyring flake module.";
    };
    doas = {
      enable = mkEnableOption "Enable doas, more secure alternative to sudo.";
    };
    polkit = {
      enable = mkEnableOption "Enable polkit.";
    };
  };

  config = {
    services.gnome.gnome-keyring.enable = cfg.gnome-keyring.enable;

    security = {
      polkit = lib.mkDefault {
        inherit (cfg.polkit) enable;
        adminIdentities = [
          "unix-user:jules"
          "unix-group:wheel"
        ];
      };

      doas = {
        inherit (cfg.doas) enable;
        extraRules = [
          {
            groups = [ "wheel" ];
            persist = true;
            keepEnv = true;
          }
        ];
      };
    };
  };
}
