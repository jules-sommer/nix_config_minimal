{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.xeta.terminal.prompt;
in
{
  options.xeta.terminal.prompt = {
    enable = mkEnableOption "Enable the prompt";
    package = mkOpt (types.nullOr types.package) null "Prompt package";
  };

  config = mkIf cfg.enable {
    programs.starship = mkIf (cfg.package == pkgs.starship) {
      enable = true;
      settings =
        let
          catppuccin = builtins.fromTOML (
            builtins.readFile (pkgs.catppuccin-starship + "/palettes/mocha.toml")
          );
        in
        catppuccin
        // {
          format = concatStrings [
            "[╭─](#ff2199)"
            " "
            "$directory"
            "$container"
            "$all"
            "($cmd_duration)"
            "$line_break"
            "[╰─](#ff2199)"
            "$jobs"
            "$status"
            "$username"
            "$hostname"
            " "
            "$character"
          ];
          right_format = "$time$shell$sudo";
          palette = "catppuccin_mocha";
          character = {
            success_symbol = "||>";
            error_symbol = "~~>";
          };
        };
    };
  };
}
