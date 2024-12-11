{
  inputs = {
    master.url = "github:nixos/nixpkgs/master";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    unfree.url = "github:numtide/nixpkgs-unfree";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };

    base24-themes.url = "github:jules-sommer/nix_b24_themes";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";

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
      inputs.nixpkgs.follows = "unstable";
    };

    zls.url = "github:zigtools/zls";
    zig-overlay.url = "github:mitchellh/zig-overlay";

    zen-browser.url = "github:MarceColl/zen-browser-flake";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

  };
  outputs =
    {
      self,
      stylix,
      master,
      base24-themes,
      home-manager,
      flake-utils-plus,
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
      inherit (builtins) mapAttrs hasAttr;
      inherit (defaultChannel.lib) filterAttrs;
      channels = mapAttrs (k: mkChannel) (
        filterAttrs (k: v: hasAttr "legacyPackages" v && hasAttr "lib" v) inputs
      );

      inherit (flake-utils-plus.lib) exportPackages exportOverlays mkFlake;

      mkChannel = channel: {
        pkgs = channel.legacyPackages;
        lib = channel.lib.extend (
          final: prev:
          import ./lib {
            inherit (channel) lib;
            inherit inputs;
          }
          // home-manager.lib
          // inputs.flake-utils-plus.lib
        );
      };

      getChannelPkgs = system: channel: channel.pkgs.${system};
      getChannelLib = channel: channel.lib;

      channelName = "unstable";
      defaultChannel = mkChannel inputs.unstable;

      # mkLib = nixpkgs: nixpkgs.lib.extend (_: _: flake.lib // home-manager.lib);

      theme = base24-themes.themes.tokyo_night_dark;
    in
    mkFlake {
      inherit self inputs;

      channelsConfig = {
        allowBroken = true;
      };

      sharedOverlays = [
        zig-overlay.overlays.default
        neovim-nightly-overlay.overlays.default
        oxalica.overlays.default
        nur.overlays.default
        self.overlay
        (final: prev: {
          inherit (defaultChannel) lib;
        })
        (_: prev: {
          inherit (zls.outputs.packages.${prev.system}) zls;
          zig = zig-overlay.packages.${prev.system}.master;
          nixvim = nixvim-flake.packages.${prev.system}.default;
        })
      ];

      hostDefaults = {
        system = "x86_64-linux";
        inherit channelName;
        extraArgs = {
          inherit
            inputs
            theme
            channels
            ;
          inherit (defaultChannel) lib;
        };
        modules = [
          home-manager.nixosModules.home-manager
          ./modules/system
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-bak";
              users.jules = import ./modules/home;
            };
          }
        ];
      };

      hosts = {
        xeta = {
          modules = [
            ./hosts/xeta
            inputs.base16.nixosModule
            stylix.nixosModules.stylix
          ];
        };
        progesterone = {
          system = "aarch64-linux";
          modules = [
            ./hosts/progesterone
          ];
        };
      };

      overlay = import ./overlays;

      outputsBuilder =
        channels:
        let
          pkgs = channels.${channelName};
          inherit (channels.${channelName}) lib;
        in
        {
          # Evaluates to `apps.<system>.custom-neovim  = utils.lib.mkApp { drv = ...; exePath = ...; };`.
          channelsFup = channels;

          overlays = exportOverlays {
            inherit (self) pkgs inputs;
          };
          packages = exportPackages self.overlays.${"x86_64-linux"} channels;

          # Evaluates to `packages.<system>.package-from-overlays = <unstable-nixpkgs-reference>.package-from-overlays`.
          # packages = lib.mergeAttrs (import ./packages {
          #   inherit (channels.${channelName}) lib;
          #   pkgs = channels.${channelName};
          # }) inputs.nixvim-flake.outputs.packages;
        };
    }
    // {
      inherit channels theme defaultChannel;
      inherit (inputs) nixvim-flake;
      # packages =
      #   system:
      #   (import ./packages/default.nix {
      #     inherit (defaultChannel) lib;
      #     inherit system;
      #     pkgs = getChannelPkgs system defaultChannel;
      #   });
    };
}
