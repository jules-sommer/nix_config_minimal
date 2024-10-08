{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    stable.url = "github:nixos/nixpkgs/24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
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

    # Ziglang
    zls.url = "github:zigtools/zls";
    zig-overlay.url = "github:mitchellh/zig-overlay";

    zen-browser.url = "github:MarceColl/zen-browser-flake";
    # local flake building zig from master
    # zig-master = {
    #   url = "/home/jules/000_dev/000_nix/nix-zig-compiler";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    #
    # zls-master = {
    #   url = "/home/jules/000_dev/010_zig/010_repos/zls";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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
      fenix,
      zen-browser,
      zig-overlay,
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

      flake = rec {
        system = "x86_64-linux";
        lib = import ./lib/default.nix {
          inherit inputs;
          inherit (nixpkgs) lib;
        };
        options = {
          compileZigFromSrc = false;
        };
        overlays = [
          # zig-overlay.overlays.default
          neovim-nightly-overlay.overlays.default
          fenix.overlays.default
          oxalica.overlays.default
          nur.overlay
          zig-overlay.overlays.default
          (_: prev: {
            zen-browser = zen-browser.packages.${prev.system}.specific;
            zig = zig-overlay.packages.${prev.system}.master;
            zig_from_src = inputs.zig-src.packages.${prev.system}.zig;
            nixvim = nixvim-flake.packages.${prev.system}.default;
            # locally compiled version of zig-master and zls
          })
          (import ./overlays/kernel/default.nix { inherit (self) inputs channels; })
          (
            _: prev:
            nixpkgs.lib.optionalAttrs options.compileZigFromSrc {
              inherit (inputs.zig-master.packages.${prev.system}) zig;
              inherit (inputs.zls-master.packages.${prev.system}) zls;
            }
          )
        ];
        packages = import ./packages/default.nix { inherit (nix) pkgs; };
      };

      theme = base24-themes.themes.tokyo_night_dark;

      nix = rec {
        pkgs = channels.master // flake.packages;
        inherit (pkgs) lib;
        inherit (flake) channels-config;
      };

      otherLib = flake.lib.mkLib (flake.lib // home-manager.lib);
      lib = mkLib inputs.nixpkgs;
    in
    assert builtins.isAttrs lib && lib ? enabled && lib ? disabled && lib ? mkOpt;
    {
      inherit lib channels theme;

      nixosConfigurations.xeta = nixpkgs.lib.nixosSystem {
        inherit (flake) system;
        inherit (nix) pkgs;
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
          ## Primary system module @ ./modules/system/default.nix
          ./modules/system
          {
            home-manager = {
              useGlobalPkgs = false;
              useUserPackages = false;
              backupFileExtension = "hm-bak";
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
            ## Primary home-manager module @ ./modules/home/default.nix
            ./modules/home
            {
              nixpkgs = {
                config.allowUnfree = true;
              };
              home = {
                packages = [
                  nix.pkgs.home-manager
                  nixvim-flake.packages.${flake.system}.default
                  zig-overlay.packages.${flake.system}.master
                ];
                stateVersion = "24.05";
              };
            }
          ];
        };
      };
    };
}
