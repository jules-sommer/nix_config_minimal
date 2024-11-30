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
    keepassxc = {
      enable = mkEnableOption "Enable keepassxc password manager and associated packages/modules.";
    };
    pam = {
      modules = {
        oath = {
          enable = mkEnableOption "Enable the OATH (one-time password) PAM module.";
        };
      };
    };
  };

  config = {
    services.gnome.gnome-keyring.enable = cfg.gnome-keyring.enable;

    environment.systemPackages =
      with pkgs;
      mkIf cfg.keepassxc.enable [
        git-credential-keepassxc
        keeweb
        kpcli
        keepmenu
        keepass-keeagent
        keepass-qrcodeview
        keepass-otpkeyprov
        keepass-keetraytotp
        keepass-keepassrpc
        keepass-charactercopy
        keepass-keepasshttp
        keepassxc
        keepassxc-go
        keepass-diff
      ];

    security = {
      polkit = {
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

      pam =
        {
        };
    };
  };
}
