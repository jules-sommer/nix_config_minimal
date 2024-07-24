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
    package = mkOpt (types.nullOr types.attrs) pkgs.linuxPackages_zen "pkgs.linuxPackages_kernel to use.";

    # other module related opts
    v4l2loopback = mkEnableOption "Enable v4l2loopback kernel modules.";
    experimentalRustModuleSupport = mkEnableOption "Enable experimental Rust kernel module support.";
    appimageSupport = mkEnableOption "Enable appimage support via binfmt.registrations.appimage.";
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
        # if v4l2loopback is enabled, find the package via the actively set `config.boot.kernelPackages`
        extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
      })
      (mkIf cfg.appimageSupport {
        binfmt.registrations.appimage = {
          wrapInterpreterInShell = false;
          interpreter = "${pkgs.appimage-run}/bin/appimage-run";
          recognitionType = "magic";
          offset = 0;
          mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
          magicOrExtension = ''\x7fELF....AI\x02'';
        };
      }) 
      # default settings if kernel module (within this flake) is enabled via `options.xeta.kernel.enable = true;`
      {
        kernelPackages = cfg.package;
        # Needed For Some Steam Games
        kernel.sysctl = {
          "vm.max_map_count" = 2147483642;
        };
        plymouth.enable = true;
      }
    ];
  };
}
