{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf types mkEnableOption mkOpt;
  cfg = config.utils.git;
in
  {
    options = {
      utils.git = {
        enable = mkEnableOption "Enable git module";
        settings = {
          user = mkOpt (types.str) null "Username for git cli authentication.";
          email = mkOpt (types.str) null "Email for git cli authentication.";
          lfs = mkOpt (types.bool) false "Enable git lfs.";
        };
      };
    };

    config = {
      programs.git = {
        enable = cfg.enable;
        userName = cfg.settings.user;
        userEmail = cfg.settings.email;
      };
    };
  }
