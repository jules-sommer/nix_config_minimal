{
  inputs = {
    master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base24-themes.url = "github:jules-sommer/nix_b24_themes";

    nur.url = "github:nix-community/NUR";

    nixvim-flake.url = "github:jules-sommer/nixvim_flake";

    nix-std = {
      url = "github:chessai/nix-std";
    };

    stylix.url = "github:danth/stylix";
    stylix.inputs.base16.follows = "base16";
    # TODO: This is a fork of base16.nix to fix a bug in a recent commit, remove when possible:
    # [as per this issue](https://github.com/danth/stylix/issues/642)
    base16.url = "github:Noodlez1232/base16.nix/slugify-fix";

    oxalica = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls.url = "github:zigtools/zls";
    zig-overlay.url = "github:mitchellh/zig-overlay";

    zen-browser.url = "github:MarceColl/zen-browser-flake";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    {
      self,
      stylix,
      master,
      nixpkgs,
      base24-themes,
      home-manager,
      zen-browser,
      zig-overlay,
      zls,
      nur,
      oxalica,
      nixvim-flake,
      neovim-nightly-overlay,
      ...
    }@inputs:
    let
      channels =
        let
          mkChannel =
            input:
            import input {
              inherit (flake) overlays system;
              config.allowUnfree = true;
            };
        in
        rec {
          master = import master {
            inherit (flake) overlays system;
            config.allowUnfree = true;
          };
          unstable = import nixpkgs {
            inherit (flake) overlays system;
            config.allowUnfree = true;
          };
          nur = import nur { nurpkgs = import nixpkgs { inherit (flake) system; }; };
        };

      mkLib = nixpkgs: nixpkgs.lib.extend (_: _: flake.lib // home-manager.lib);

      flake = rec {
        system = "x86_64-linux";
        localSystem = {
          inherit system;
          gcc.arch = "znver4";
          gcc.tune = "znver4";
        };
        lib = import ./lib/default.nix {
          inherit inputs;
          inherit (nixpkgs) lib;
        };
        options = {
          compileZigFromSrc = false;
        };
        overlays = [
          zig-overlay.overlays.default
          neovim-nightly-overlay.overlays.default
          oxalica.overlays.default
          nur.overlay
          (_: prev: {
            inherit (zls.outputs.packages.${prev.system}) zls;
            zen-browser = zen-browser.packages.${prev.system}.specific;
            zig = zig-overlay.packages.${prev.system}.master;
            nixvim = nixvim-flake.packages.${prev.system}.default;
          })
        ];
        packages = import ./packages/default.nix { inherit (nix) pkgs; };
      };

      theme = base24-themes.themes.tokyo_night_dark;

      nix = rec {
        pkgs = channels.unstable // flake.packages;
        inherit (pkgs) lib;
        inherit (flake) channels-config;
      };
      lib = mkLib nix.pkgs;
    in
    assert lib.assertMsg (
      builtins.isAttrs lib && lib ? enabled && lib ? disabled && lib ? mkOpt
    ) "failed to build flake library correctly.";
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
          inputs.base16.nixosModule
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          ## Primary system module @ ./modules/system/default.nix
          ./modules/system
          {
            boot.tmp.useTmpfs = true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
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
            stylix.homeManagerModules.stylix
            {
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
