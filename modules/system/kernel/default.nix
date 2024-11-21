{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOpt
    types
    mkEnableOption
    mkIf
    ;
  cfg = config.xeta.kernel;
in
{
  options.xeta.kernel = {
    enable = mkEnableOption "Enable kernel configuration.";
    package =
      mkOpt (types.nullOr types.attrs) pkgs.linuxPackages_xanmod_latest
        "pkgs.linuxPackages_kernel to use.";

    # other module related opts
    modules =
      mkOpt (types.listOf types.package) [ ]
        "List of Linux kernel modules to build the kernel with.";

    # v4l2loopback = mkEnableOption "Enable v4l2loopback kernel modules.";
    experimentalRustModuleSupport = mkEnableOption "Enable experimental Rust kernel module support.";
    appimageSupport = mkEnableOption "Enable appimage support via binfmt.registrations.appimage.";
  };

  config = mkIf cfg.enable {
    programs.appimage = mkIf cfg.appimageSupport {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: [
          pkgs.ffmpeg
          pkgs.imagemagick
        ];
      };
    };

    # so perf can find kernel modules
    systemd.tmpfiles.rules = [
      "L /lib - - - - /run/current/system/lib"
    ];

    boot = lib.mkMerge [
      {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
      }
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
      (mkIf ((lib.length cfg.modules) > 0) {
        kernelModules =
          with pkgs.linuxPackages_linux_xanmod_latest;
          [
            v4l2loopback
            zfs_unstable
            virtio_vmmci
            virtualbox
            virtualboxGuestAdditions
            zenergy
            zenpower
            ryzen-smu
            rr-zen_workaround
          ]
          // cfg.modules;
      })

      {
        kernelPackages = pkgs.linuxPackages_xanmod_latest;
        kernelParams = [ ];
        kernel = {
          enable = true;
          sysctl = {
            "vm.max_map_count" = 2147483642; # Needed For Some Steam Games
            "kernel.perf_event_paranoid" = -1; # needed for tracing/debugging programs like rr
            "kernel.kptr_restrict" = lib.mkForce 0; # transparent ptr addresses for kernel memory
          };
        };

        plymouth.enable = true;
      }
    ];
  };
}
