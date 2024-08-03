{
  lib,
  config,
  pkgs,
  theme,
  ...
}:
let
  inherit (lib)
    mkOpt
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.xeta.terminal;
in
{
  options.xeta.terminal = {
    enable = mkEnableOption "Terminal configuration submodule, includes modules for terminal emulator, shell, environment, etc.";
  };
  config = mkIf (cfg.enable) {
    imports = [
      ./emulator
      ./shell
    ];
  };
}
