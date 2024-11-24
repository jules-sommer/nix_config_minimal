{
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (lib) disabled enabled;
  homeDirs = lib.getHomeDirs "jules";
in
{
  imports = [
    ./hardware
    ./dev
    ./apps
    ./user
    ./audio
    ./kernel
    ./networking
    ./theming
    ./services
    ./fonts
    ./desktop
    ./terminal
  ];

  config = {
    xeta = {
      security = {
        gnome-keyring = enabled;
        doas = enabled;
        polkit = enabled;

        pam.modules = {
          oath = enabled;
        };
      };
      kernel = {
        enable = true;
        package = pkgs.linuxKernel.kernels.linux_xanmod_latest;
        appimageSupport = true;
      };
      fonts = enabled;
      networking = {
        enable = true;
        tcp_bbr = enabled;
      };
      theming.stylix = enabled;
      apps = {
        kmail = enabled;
        okular = enabled;
        libreoffice = enabled;
        calculator = enabled;
      };
      terminal = {
        enable = true;
        shell.fish = true;
        emulator = enabled;
        prompt = enabled;
      };
      services = {
        proton-bridge = enabled;
        hydroxide = disabled;
        ollama = disabled;
        rustdesk = disabled;
      };
      desktop = {
        hyprland = {
          enable = false;
          xwayland = true;
        };
        plasma6 = enabled;
        river = disabled;
      };
      development = {
        rust = enabled;
        zig = enabled;
        typescript = enabled;
        nix = enabled;
        ocaml = enabled;
        go = enabled;
        clang = enabled;
        python = enabled;
        odin = enabled;

        extras = {
          cli =
            with pkgs;
            [
            ];
        };
      };
      audio = {
        pipewire = enabled;
      };
    };

    nix.settings.system-features = lib.mkForce [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
      "gccarch-znver4"
    ];

    nix.settings.extra-system-features = lib.mkForce [
      "gccarch-znver4"
    ];

    programs = {
      nix-ld.enable = true;
      command-not-found.enable = false;
      nix-index = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
      steam = {
        enable = true;
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
      mtr.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    networking = {
      hostName = "xeta";
      networkmanager.enable = true;
      firewall.enable = false;
    };

    # Set your time zone.
    time.timeZone = "America/Toronto";

    hardware.amdgpu = {
      opencl.enable = true;
      initrd.enable = true;
      amdvlk = {
        enable = true;
        supportExperimental = enabled;
        support32Bit = enabled;
        settings = { };
      };
    };

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "${homeDirs.home}/000_dev/000_nix/nix_config_minimal";
    };

    environment = {
      variables = {
        LOG_ICONS = "true";
        KITTY_CONFIG_DIRECTORY = "/home/jules/.config/kitty";
        KITTY_ENABLE_WAYLAND = "1";
        EDITOR = "nvim";
        NIX_BUILD_CORES = 8;
        GC_INITIAL_HEAP_SIZE = "8G";
      };

      systemPackages = with pkgs; [
        tmux
        # code-cursor
        tor-browser
        nur.repos.shadowrz.klassy
        protonvpn-gui
        protonvpn-cli
        # prismlauncher
        # optifine
        gimp-with-plugins
        radeontop
        nixfmt-rfc-style
        lact
        neovim
        # hydroxide
        bitwarden
        bitwarden-cli
        home-manager
        nixVersions.git # install latest (git master) version of nix pkg manager
        qbittorrent
        btop
        mpv
        vlc
        # metasploit
        # armitage
        kitty
        localsend
      ];
    };

    hardware.sane = {
      enable = true;
      openFirewall = true;
      netConf = "192.168.1.4";
    };

    services = {
      saned.enable = true;
      printing.enable = true;
    };

    system.stateVersion = "24.05";
  };
}
