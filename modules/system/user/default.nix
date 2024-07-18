{
  lib,
  pkgs,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.system;
in
{
  options.xeta.system = {
  };

  config = {
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    # environment.etc = lib.mapAttrs' (name: value: {
    #   name = "${cfg.user.home}/.nix-defexpr/channels_root/nixos/${name}";
    #   value.source = value.flake;
    # }) config.nix.registry;

    # Configure the Nix package manager
    nix = {
      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
        (lib.filterAttrs (_: lib.isType "flake")) inputs
      );
      nixPath = [ "/home/jules/.nix-defexpr/channels_root/nixos" ];

      settings =
        let
          users = [
            "root"
            "jules"
          ];
        in
        {
          warn-dirty = false;
          # Enable flakes and new 'nix' command
          experimental-features = "nix-command flakes";
          # Deduplicate and optimize nix store
          auto-optimise-store = true;
          # Use binary caches
          substituters = [
            "https://hyprland.cachix.org"
            "https://cache.nixos.org"
          ];
          trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];
          http-connections = 50;
          log-lines = 50;
          sandbox = "relaxed";

          trusted-users = users;
          allowed-users = users;
        };
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
      # flake-utils-plus
      # generateRegistryFromInputs = true;
      # generateNixPathFromInputs = true;
      # linkInputs = true;
    };

    time.timeZone = "America/Toronto";
    i18n.defaultLocale = "en_CA.UTF-8";
    users.users.jules = {
      isNormalUser = true;
      useDefaultShell = true;
      uid = 1000;
      homeMode = "755";
      extraGroups = [
        "wheel"
        "users"
        "networkmanager"
        "wheel"
        "vboxusers"
        "docker"
        "wireshark"
        "libvirtd"
        "fuse"
      ];
      packages = with pkgs; [
        floorp
        vencord
        starship
        webcord
        git
        tree
      ];
    };
  };
}
