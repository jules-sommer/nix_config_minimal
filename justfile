build action flake="xeta":
  sudo nixos-rebuild {{action}} --flake .#{{flake}}

show:
  nix flake show

check:
  nix flake check

build-home flake="xeta":
  home-manager switch --flake .#{{flake}}
