{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.kernel;
in
{
  options.xeta.kernel = {
    enable = mkEnableOption "Enable kernel configuration.";
    v4l2loopback = mkOpt (types.nullOr types.bool) true "Enable v4l2loopback kernel modules.";
    experimentalRustModuleSupport = mkOpt (types.nullOr types.bool) true "Enable experimental Rust kernel module support.";
    # package = mkOpt (types.nullOr (
    #   types.enum (
    #     with pkgs;
    #     [
    #       linuxPackages_latest
    #       linuxPackages_latest-libre
    #       linuxPackages_latest_hardened
    #       linuxPackages_latest_xen_dom0
    #       linuxPackages_zen
    #     ]
    #   )
    # )) null "The kernel package to use";
  };

  config = mkIf (cfg.enable) {
    assertions = [
      # {
      #   # if enabled, package must be set
      #   assertion = cfg.package != null;
      #   message = "[xeta.nixos.kernel] config.xeta.kernel.package must be set if config.xeta.kernel.enable is true";
      # }
    ];

    boot = lib.mkMerge [
      (mkIf cfg.experimentalRustModuleSupport {
        kernelPatches = [
          {
            name = "Rust Support";
            patch = null;
            features = {
              rust = true;
            };
          }
        ];
      })
      (mkIf cfg.v4l2loopback {
        kernelModules = [ "v4l2loopback" ];
        extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
      })
      {
        kernelPackages = pkgs.linuxPackages_latest;
        # Needed For Some Steam Games
        kernel.sysctl = {
          "vm.max_map_count" = 2147483642;
        };

        binfmt.registrations.appimage = {
          wrapInterpreterInShell = false;
          interpreter = "${pkgs.appimage-run}/bin/appimage-run";
          recognitionType = "magic";
          offset = 0;
          mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
          magicOrExtension = ''\x7fELF....AI\x02'';
        };
        plymouth.enable = true;
      }
    ];
  };
}
