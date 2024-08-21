{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) enabled disabled getHomeDirs;

  homeDirs = getHomeDirs "jules";
in
{
  imports = [ ./modules/system/default.nix ];

  xeta = {
    kernel = {
      enable = true;
      package = pkgs.linuxPackages_zen;
      v4l2loopback = true;
      experimentalRustModuleSupport = false;
      appimageSupport = true;
    };
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
    services = {
      hydroxide = enabled;
      ollama = enabled;
    };
    development = {
      rust = enabled;
      zig = enabled;
      typescript = enabled;
      nix = enabled;
      ocaml = enabled;
      go = enabled;

      extras = {
        cli = with pkgs; [ lazygit ];
      };
    };
    audio = {
      pipewire = enabled;
    };
  };

  programs.nix-ld.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
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

  networking.hostName = "xeta";

  # networking.wireless.enable = true; 
  networking.networkmanager.enable = true;

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

  console = {
    font = "JetBrains Mono Nerd Font";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  environment.variables = {
    LOG_ICONS = "true";
    KITTY_CONFIG_DIRECTORY = "${homeDirs.home}/kitty";
    EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    cosmic-comp
    cosmic-greeter
    nur.repos.shadowrz.klassy
    prismlauncher
    optifine
    jre8
    jre_minimal
    jre17_minimal
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
    font-awesome
    jetbrains-mono
    qbittorrent
    btop
    mpv
    vlc
    metasploit
    armitage
    kitty
    fira-code
    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "Noto"
        "RobotoMono"
        "ZedMono"
        "Ubuntu"
        "UbuntuMono"
        "NerdFontsSymbolsOnly"
        "SpaceMono"
        "UbuntuSans"
        "Hack"
        "FiraCode"
      ];
    })
  ];

  services.xserver.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.printing.enable = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  networking.firewall.enable = false;
  system.stateVersion = "24.05";
}
