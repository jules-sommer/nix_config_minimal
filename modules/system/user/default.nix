{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  options.xeta.system =
    {
    };

  config = {
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    environment.etc = lib.mapAttrs' (name: value: {
      name = "/home/jules/.nix-defexpr/channels_root/nixos/${name}";
      value.source = value.flake;
    }) config.nix.registry;

    # Configure the Nix package manager
    nix = {
      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
        (lib.filterAttrs (_: lib.isType "flake")) inputs
      );

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
    };

    time.timeZone = "America/Toronto";
    i18n.defaultLocale = "en_CA.UTF-8";
    users.users.jules = {
      isNormalUser = true;
      useDefaultShell = true;
      uid = 1000;
      homeMode = "755";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwxJcAWuHkKy/Ar37aIoqg34CDcZu7/bh978nYkOgzj jules"
      ];
      extraGroups = [
        "wheel"
        "users"
        "networkmanager"
        "vboxusers"
        "wireshark"
        "libvirtd"
        "fuse"
      ];
      packages = with pkgs; [
        floorp
        vencord
        webcord
      ];
    };
  };
}
