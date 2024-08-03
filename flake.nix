{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    stable.url = "github:nixos/nixpkgs/24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base24-themes.url = "github:jules-sommer/nix_b24_themes";

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

    pyprland = {
      url = "github:hyprland-community/pyprland";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      stylix,
      unstable,
      stable,
      base24-themes,
      home-manager,
      zig-overlay,
      fenix,
      oxalica,
      neovim-nightly-overlay,
      ...
    }@inputs:
    let
      channels = {
        master = import nixpkgs { inherit (flake) system; };
        unstable = import unstable { inherit (flake) system; };
        stable = import stable { inherit (flake) system; };
      };

      mkLib = nixpkgs: nixpkgs.lib.extend (self: super: flake.lib // home-manager.lib);

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

      theme = base24-themes.themes.tokyo_night_dark;

      nix = rec {
        pkgs = channels.master;
        lib = pkgs.lib;
      };

      lib = mkLib inputs.nixpkgs;
    in
    assert builtins.isAttrs lib && lib ? enabled && lib ? disabled && lib ? mkOpt;
    {
      inherit lib channels theme;
      inherit (nix) pkgs;
      nixosConfigurations.xeta = nixpkgs.lib.nixosSystem {
        inherit (flake) system;
        specialArgs = {
          inherit
            inputs
            lib
            theme
            channels
            ;
        };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = false;

            nixpkgs = {
              config.allowUnfree = true;
              overlays = flake.overlays;
            };
          }
        ];
      };

      homeConfigurations = {
        xeta = lib.homeManagerConfiguration {
          inherit (nix) pkgs;
          extraSpecialArgs = {
            inherit
              inputs
              lib
              theme
              channels
              ;
          };
          modules = [
            ./modules/home/default.nix
            {
              home = {
                username = "jules";
                homeDirectory = "/home/jules";
                packages = [ nix.pkgs.home-manager ];
                stateVersion = "24.05";
              };
            }
          ];
        };
      };
    };
}
