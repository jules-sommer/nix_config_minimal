{
  lib,
  config,
  pkgs,
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
  config = mkIf (cfg.enable) {
    users.users = {
      jules = {
        shell = pkgs.fish;
        packages = with pkgs; [
          eza
          fzf
          fd
          jaq
          jq
          bat
          file
          git
        ];
      };
    };
  };
}
