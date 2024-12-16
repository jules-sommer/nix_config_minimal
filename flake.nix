{
  inputs = {
    master.url = "github:nixos/nixpkgs/master";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };

    utils.url = "github:numtide/flake-utils";

    base24-themes.url = "github:jules-sommer/nix_b24_themes";

    nur.url = "github:nix-community/NUR";

    nixvim-flake.url = "github:jules-sommer/nixvim_flake";

    oxalica = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "unstable";
    };
    stylix.url = "github:danth/stylix";

    zls.url = "github:zigtools/zls";
    zig-overlay.url = "github:mitchellh/zig-overlay";

    zen-browser.url = "github:MarceColl/zen-browser-flake";

    channels.url = "path:/home/jules/000_dev/000_nix/channels";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

  };
  outputs =
    {
      self,
      nixpkgs,
      stylix,
      utils,
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

      inherit (utils.lib) system;
      inherit (inputs.channels)
        importChannel
        withChannels
        channels
        makeChannelsInstance
        ;
      defaultSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      libExtensions = nixpkgs.lib // home-manager.lib // self.lib // { __been-merged = true; };
      extendLibDefaults = extendLib libExtensions;
      extendLib = extensions: lib: (lib.extend (_: prev: libExtensions // prev));

      inherit (nixpkgs.lib) nixosSystem assertMsg;

      theme = base24-themes.themes.tokyo_night_dark;

      sharedOverlays =
        channels: with inputs; [
          zig-overlay.overlays.default
          neovim-nightly-overlay.overlays.default
          oxalica.overlays.default
          nur.overlays.default
          (_: prev: {
            inherit (channels.unfree.pkgs)
              masterpdfeditor
              graphite-cli
              steam
              steam-unwrapped
              ;
          })
        ];

      sharedModules = [
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
      ];

      users = {
        jules = {
          primary = true;
        };
      };

      hosts = {
        xeta = {
          system = system.x86_64-linux;
          defaultChannel = channels.unstable;
          src = ./hosts/xeta;
          overlays = [
            (final: prev: {
              zen-browser = zen-browser.packages.${prev.system}.specific;
            })
          ];
          modules =
            [
            ];
          stateVersion = "24.05";
        };
        progesterone = {
          system = system.aarch64-linux;
          defaultChannel = channels.unstable;
          src = ./hosts/progesterone;

          stateVersion = "23.11";
        };
      };

      withHostChannels = host: withChannels host.system host.defaultChannel;
    in
    {
      inherit
        theme
        withHostChannels
        hosts
        users
        ;

      nixosConfigurations = builtins.mapAttrs (
        name:
        {
          defaultChannel ? channels.unstable,
          overlays ? [ ],
          modules ? [ ],
          src,
          ...
        }@host:
        let
          inherit (host) system;
        in
        withHostChannels host (
          channels:
          let
            overlaysApplied = sharedOverlays channels ++ overlays;
            pkgs = importChannel channels.default {
              inherit system;
              overlays = overlaysApplied;
            };
            lib = extendLibDefaults pkgs.lib;
            mkArgs =
              args:
              {
                inherit
                  lib
                  pkgs
                  self
                  inputs
                  channels
                  users
                  ;

                host = host // {
                  inherit name;
                };
              }
              // args;
            modules =
              let
                systemModules = self.nixosModules.default { inherit pkgs lib system; };
                homeModules = self.homeManagerModules.default { inherit pkgs lib system; };
                hostModules = host.modules or [ ];
              in
              [
                systemModules
                src
                (
                  { pkgs, config, ... }:
                  {
                    _module.args = mkArgs { };

                    home-manager = {
                      useGlobalPkgs = true;
                      useUserPackages = true;

                      sharedModules = [
                        homeModules
                      ];
                    };

                  }
                )

              ]
              ++ hostModules;
          in
          nixosSystem {
            inherit
              system
              pkgs
              lib
              ;
            specialArgs = mkArgs { };
            modules = [
              (
                { pkgs, ... }:
                {
                }
              )
            ] ++ modules ++ sharedModules;
          }

        )
      ) hosts;

      homeManagerModules.default =
        {
          pkgs,
          lib,
          system,
          config ? { },
        }:
        assert (assertMsg (builtins.hasAttr "__been-merged" lib) "lib has not been correctly extended.");
        import ./modules/home/default.nix {
          inherit
            pkgs
            lib
            system
            config
            ;
        };
      nixosModules.default =
        {
          pkgs,
          lib,
          system,
          config ? { },
        }:
        assert (assertMsg (builtins.hasAttr "__been-merged" lib) "lib has not been correctly extended.");
        import ./modules/system/default.nix {
          inherit
            pkgs
            lib
            system
            config
            ;
        };

      lib = import ./lib/default.nix {
        inherit (nixpkgs) lib;
      };
    };
}
