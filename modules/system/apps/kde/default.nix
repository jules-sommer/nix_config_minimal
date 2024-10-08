{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOpt mkIf mkMerge;
  cfg = config.xeta.apps.kde;
in
{
  options.xeta.apps.kde = {
    kmail = mkEnableOpt "Enable KMail from kdePackages.";
  };

  config = {
    environment.systemPackages =
      with pkgs.kdePackages;
      (mkMerge [
        (mkIf (cfg.kmail.enable) [
          kmail
          kmail-account-wizard
          kmailtransport
          kdepim-addons # for addressbook and other plugins
        ])
      ]);
  };
}
