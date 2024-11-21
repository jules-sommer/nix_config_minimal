{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.xeta.apps;
in
{
  options.xeta.apps = {
    kmail = {
      enable = mkEnableOption "Enable KMail from kdePackages.";
    };
  };

  config = {
    environment.systemPackages =
      with pkgs.kdePackages;
      (mkMerge [
        (mkIf cfg.kmail.enable [
          kmail
          kmail-account-wizard
          kmailtransport
          kdepim-addons # for addressbook and other plugins
        ])
      ]);
  };
}
