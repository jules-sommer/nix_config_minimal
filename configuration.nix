{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) enabled disabled;
in
{
  imports = [
    ./modules/system/default.nix
  ];

  xeta = {
    kernel = {
      enable = true;
      v4l2loopback = true;
    };
    networking = {
      enable = true;
      tcp_bbr = enabled;
    };
    apps = {
      utils = {
        calculator = enabled; 
      };
    };
    development = {
      rust = enabled;
      zig = enabled;
      typescript = enabled;
      nix = enabled;
      ocaml = enabled;
      go = enabled;

      extras = {
        cli = with pkgs; [
          lazygit

        ];
      };
    };
    audio = {
      pipewire = enabled;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "xeta"; 

  # networking.wireless.enable = true; 
  networking.networkmanager.enable = true; 

  # Set your time zone.
  time.timeZone = "America/Toronto";

  console = {
    font = "JetBrains Mono Nerd Font";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  environment.variables = {
    LOG_ICONS = "true";
    EDITOR = "nvim";
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      ubuntu_font_family
      jetbrains-mono
      fira-code
      roboto
      roboto-mono
      roboto-serif
      font-awesome
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      (nerdfonts.override {
        fonts = [
          "Hack"
          "JetBrainsMono"
          "FiraCode"
        ];
      })
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "JetBrains Mono" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    home-manager
    helix
    nixVersions.git # install latest (git master) version of nix pkg manager
    font-awesome
    jetbrains-mono
    qbittorrent
    mpv
    vlc
    metasploit
    armitage
    kitty
    fira-code
    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
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

  services.openssh.enable = true;
  networking.firewall.enable = false;
  system.stateVersion = "24.05";
}
