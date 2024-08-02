{ ... }: {
  imports = [
    ./dev/default.nix
    ./apps/default.nix
    ./user/default.nix
    ./audio/default.nix
    ./kernel/default.nix
    ./networking/default.nix
    ./theming/default.nix
  ];
}
