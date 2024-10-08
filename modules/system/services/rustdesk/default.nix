{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.xeta.services.rustdesk;
in
{
  options = {
    xeta.services.rustdesk = {
      enable = mkEnableOption "rustdesk";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # rustdesk
    ];

    services.rustdesk-server = {
      enable = true;
      package = pkgs.rustdesk-server;
      relayIP = "127.0.0.1";
      openFirewall = true;
    };
  };
}
