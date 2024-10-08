{ lib, ... }:
with lib;
{
  options.xeta.desktop.river = {
    enable = mkEnableOption "river window manager";
  };
}
