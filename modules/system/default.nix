{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) disabled enabled;
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
      kernel = {
        enable = true;
        package = pkgs.linuxPackages_zen;
        v4l2loopback = true;
        experimentalRustModuleSupport = false;
        appimageSupport = true;
      };
      fonts = enabled;
      networking = {
        enable = true;
        tcp_bbr = enabled;
      };
      theming = {
        stylix = enabled;
      };
      apps = {
        kde = {
          kmail = enabled;
        };
        pdf = {
          okular = enabled;
        };
        utils = {
          calculator = enabled;
        };
      };
      terminal = {
        enable = true;
        shell = enabled;
        emulator = {
          enable = true;
        };
      };
      services = {
        hydroxide = enabled;
        ollama = enabled;
        rustdesk = enabled;
      };
      desktop = {
        hyprland = {
          enable = true;
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
          cli = with pkgs; [
            tmux
            lazygit
          ];
        };
      };
      audio = {
        pipewire = enabled;
      };
    };

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

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;

      binfmt.registrations.appimage = {
        wrapInterpreterInShell = false;
        interpreter = "${pkgs.appimage-run}/bin/appimage-run";
        recognitionType = "magic";
        offset = 0;
        mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
        magicOrExtension = ''\x7fELF....AI\x02'';
      };
    };
    networking = {
      hostName = "xeta";
      # networking.wireless.enable = true;
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

    environment = {
      variables = {
        LOG_ICONS = "true";
        KITTY_CONFIG_DIRECTORY = "/home/jules/.config/kitty";
        KITTY_ENABLE_WAYLAND = "1";
        EDITOR = "nvim";
      };

      systemPackages = with pkgs; [
        vivaldi
        code-cursor
        brave
        tor-browser
        cosmic-comp
        cosmic-greeter
        nur.repos.shadowrz.klassy
        protonvpn-gui
        protonvpn-cli
        prismlauncher
        optifine
        gimp-with-plugins
        radeontop
        nixfmt-rfc-style
        lact
        neovim
        hydroxide
        bitwarden
        bitwarden-cli
        home-manager
        helix
        nixel
        lix
        nixVersions.git # install latest (git master) version of nix pkg manager
        qbittorrent
        btop
        mpv
        vlc
        metasploit
        armitage
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
