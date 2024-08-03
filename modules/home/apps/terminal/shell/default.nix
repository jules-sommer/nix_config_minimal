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
  cfg = config.xeta.terminal.emulator;
in
{
  options.xeta.terminal.shell = {
    enable = mkEnableOption "Terminal shell configuration";
    package = mkOpt (types.nullOr types.package) null "The default shell to use";
  };

  config = mkIf (cfg.enable) {
    assertions = [
      { assertion = (cfg.package != null) && (builtins.elem (cfg.package) [ pkgs.nushell ]); }
    ];

    programs = {
      nushell = mkIf (cfg.package == pkgs.nushell) {
        enable = true;
        package = cfg.package;
        settings = {
          enable_ansi_colors = true;
          enable_tab_completion = true;
          default_keybindings = true;
          autosuggestions.enable = true;
          autosuggestions.key_bindings = {
            ctrl-space = {
              name = "autosuggest";
              keybinding = "ctrl-space";
            };
          };
        };
      };
    };
  };
}
