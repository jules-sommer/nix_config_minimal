{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.xeta.security;
in
{
  imports = [
    ./ssh/default.nix
    ./rustdesk/default.nix
    ./ollama/default.nix
    ./hydroxide/default.nix
    ./proton-bridge/default.nix
  ];

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

      pam = {
        inherit (cfg.pam.modules) oath;
        # oath = {
        #   inherit (cfg.pam.modules.oath) enable;
        # };
      };
    };
  };
}
