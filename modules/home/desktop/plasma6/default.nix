{ lib, ... }:
with lib;
{
  options.xeta.desktop.plasma6 = {
    enable = mkEnableOption "plasma6 desktop environment";
  };
}
