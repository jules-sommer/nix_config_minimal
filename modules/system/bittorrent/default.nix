{ config, pkgs, lib, ... }: 
let
  inherit (lib) mkOpt mkEnableOption; 
  cfg = config.xeta.bittorrent;
in
{
  options.xeta.bittorrent = {
    enable = mkEnableOption "Enable system bittorrent daemon / client configuration."; 
  };

  config = {
    services.transmission = {
      inherit (cfg) enable;
      package = pkgs.transmission_4;
    }; 
  };
}
