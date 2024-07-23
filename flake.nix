{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    stable.url = "github:nixos/nixpkgs/24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";

    nix-std = {
      url = "github:chessai/nix-std";
    };

    stylix.url = "github:danth/stylix";
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    oxalica = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyprland = {
      url = "github:hyprland-community/pyprland";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, nixpkgs, stylix, unstable, stable, home-manager, zig-overlay, fenix, oxalica, neovim-nightly-overlay, ... }@inputs:
    let
      channels = {
        master = import nixpkgs {
          inherit (flake) system;
        };
        unstable = import unstable {
          inherit (flake) system;
        };
        stable = import stable {
          inherit (flake) system;
        };
      };
      flake = {
        system = "x86_64-linux";
        lib = import ./lib/default.nix {
          inherit inputs;
          inherit (nixpkgs) lib;
        };
        overlays = [
          zig-overlay.overlays.default
          neovim-nightly-overlay.overlays.default
          fenix.overlays.default
          oxalica.overlays.default
          (import ./overlays/kernel/default.nix { inherit (self) inputs channels; })
        ];
      };

      nix = rec {
        pkgs = channels.master;
        lib = pkgs.lib; 
      };

      lib = nix.lib // flake.lib;
    in
    {
      inherit lib channels;
      nixosConfigurations.xeta = nixpkgs.lib.nixosSystem rec {
        inherit (flake) system;
        specialArgs = {
          inherit inputs system lib; 
        };
        modules = [
          ({ config, inputs, ... }: { 
            config = {
              _module.args = lib.mkDefault { 
                inherit config lib;
                inherit (nix) pkgs;
                inherit (self) inputs;
              };
              nixpkgs = {
                config.allowUnfree = true;
                overlays = flake.overlays;
              };
            };
          })
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };

      homeConfigurations = {
        "jules@xeta" = home-manager.lib.homeManagerConfiguration {
          inherit (nix) pkgs;
          extraSpecialArgs = { 
            inherit lib;
            inherit (nix) pkgs;
            inherit (self) inputs;
          };

          modules = [
            ({ config, inputs, ... }: {
              config = {
                _module.args = lib.mkDefault {
                  inherit config lib;
                  inherit (nix) pkgs;
                  inherit (self) inputs;
                };
                nixpkgs = {
                  config.allowUnfree = true;
                  overlays = flake.overlays;
                };
              };
            })
            ./modules/home/default.nix
          ];
        };
      };
    };
} 
