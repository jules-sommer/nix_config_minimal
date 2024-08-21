{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    ;
  cfg = config.xeta.terminal;
in
{
  imports = [
    ./emulator
    ./shell
    ./prompt
  ];

  options.xeta.terminal = {
    enable = mkEnableOption "Terminal configuration submodule, includes modules for terminal emulator, shell, environment, etc.";
  };

  config = mkIf cfg.enable { };
}
