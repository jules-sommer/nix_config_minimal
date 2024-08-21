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

    nur.url = "github:nix-community/NUR";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";

    nixvim-flake.url = "/home/jules/000_dev/000_nix/nixvim_flake";

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

    # local flake building zig from master
    zig-master = {
      url = "/home/jules/000_dev/000_nix/nix-zig-compiler";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls-master = {
      url = "/home/jules/000_dev/010_zig/010_repos/zls";
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

    river = {
      url = "/home/jules/000_dev/010_zig/010_repos/river";
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
      zig-master,
      zls-master,
      fenix,
      nur,
      oxalica,
      nixvim-flake,
      neovim-nightly-overlay,
      ...
    }@inputs:
    let
      channels = {
        master = import nixpkgs {
          inherit (flake) system overlays;
          config.allowUnfree = true;
        };
        unstable = import unstable { inherit (flake) system; };
        stable = import stable { inherit (flake) system; };
        nur = import nur { nurpkgs = import nixpkgs { inherit (flake) system; }; };
      };

      mkLib = nixpkgs: nixpkgs.lib.extend (_: _: flake.lib // home-manager.lib);

      flake = {
        system = "x86_64-linux";
        lib = import ./lib/default.nix {
          inherit inputs;
          inherit (nixpkgs) lib;
        };
        overlays = [
          # zig-overlay.overlays.default
          neovim-nightly-overlay.overlays.default
          fenix.overlays.default
          oxalica.overlays.default
          nur.overlay
          (_: prev: {
            nixvim = nixvim-flake.packages.${prev.system}.default;
            zig = zig-master.packages.${prev.system}.zigPrebuilt;
            inherit (zls-master.packages.${prev.system}) zls;
          })
          (import ./overlays/kernel/default.nix { inherit (self) inputs channels; })
        ];
        packages = import ./packages/default.nix { inherit (nix) pkgs; };
      };

      theme = base24-themes.themes.tokyo_night_dark;

      nix = rec {
        pkgs = channels.master // flake.packages;
        inherit (pkgs) lib;
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
          inherit (flake) system;
        };
        modules = [
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          ./modules/system/default.nix
          {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = false;
            nixpkgs = {
              inherit (flake) overlays;
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
            inherit (flake) system;
            inherit (nix) pkgs;
          };
          modules = [
            ./modules/home/default.nix
            {
              nixpkgs = {
                config.allowUnfree = true;
              };
              home = {
                packages = [
                  nix.pkgs.home-manager
                  nixvim-flake.packages.${flake.system}.default
                  zig-master.packages.${flake.system}.zigPrebuilt
                ];
                stateVersion = "24.05";
              };
            }
          ];
        };
      };
    };
}
