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
  cfg = config.xeta.terminal.shell;
  enableIntegrations = {
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };
in
{
  options.xeta.terminal.shell = {
    enable = mkEnableOption "Terminal shell configuration";
    package = mkOpt (types.nullOr types.package) null "The default shell to use";
    settings = {
      zoxide = {
        enable = mkEnableOption "Zoxide integration";
        package = mkOpt (types.nullOr types.package) null "The zoxide package to use";
      };
      carapace = {
        enable = mkEnableOption "Carapace integration";
        package = mkOpt (types.nullOr types.package) null "The carapace package to use";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.package != null) && (builtins.elem cfg.package [ pkgs.nushell ]);
        message = "Invalid shell package";
      }
    ];

    home.packages = with pkgs; [ nufmt ];

    programs = {
      zoxide =
        mkIf cfg.settings.zoxide.enable {
          enable = true;
          package = cfg.settings.zoxide.package or pkgs.zoxide;
        }
        // enableIntegrations;

      carapace =
        mkIf cfg.settings.carapace.enable {
          enable = true;
          package = cfg.settings.carapace.package or pkgs.carapace;
        }
        // enableIntegrations;

      nushell = mkIf (cfg.package == pkgs.nushell) {
        enable = true;
        inherit (cfg) package;
        extraEnv = builtins.readFile ./profiles/nushell/zoxide.nu;
        shellAliases = {
          ll = "ls -la";
          ff = "fastfetch";
          br = "broot -hips";
          yank = "wl-copy";
          put = "wl-paste";
          sync = "rsync -avh --progress";
          mirror_sync = "rsync -avzHAX --delete --numeric-ids --info=progress2";
          cp = "rsync";
          cd = "z";
          ci = "zi";
          tree = "dutree";
          clone = "gix clone";
        };

        configFile.source = ./profiles/nushell/config.nu;
        envFile.source = ./profiles/nushell/env.nu;
        loginFile.source = ./profiles/nushell/login.nu;
      };
      fish = {
        enable = true;
        functions.fish_greeting.body = "";
        plugins = with pkgs.fishPlugins; [
          {
            name = "z";
            src = z;
          }
          {
            name = "fifc";
            src = fifc;
          }
          {
            name = "fzf";
            src = fzf;
          }
          {
            name = "forgit";
            src = forgit;
          }
          {
            name = "autopair";
            src = autopair;
          }
        ];
      };
    };
  };
}
