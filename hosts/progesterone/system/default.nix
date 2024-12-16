{
  lib,
  config,
  pkgs,
  host,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./hardware
  ];

  config = {
    networking = {
      hostName = host.name;
      wireless.enable = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
          80
          443
        ];
        allowedUDPPorts = [ 53 ];
      };
    };

    time.timeZone = "America/Toronto";

    i18n.defaultLocale = mkDefault "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = lib.mkDefault "us";
      useXkbConfig = true; # use xkb.options in tty.
    };

    services = {
      xserver = {
        enable = true;
        xkb.layout = "us";
        xkb.options = "eurosign:e,caps:escape";
      };
      printing.enable = true;
      openssh = {
        enable = true;
        openFirewall = true;
      };
    };

    services.pipewire = {
      enable = true;
    };

    users.users.jules = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh = {
        authorizedKeys = {

        };
      };
      packages = with pkgs; [
        tree
      ];
    };

    environment.systemPackages = with pkgs; [
      vim
      neovim
      wget
    ];

    programs = {
      mtr.enable = true;
      localsend = {
        enable = true;
        openFirewall = true;
      };
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    system = {
      stateVersion = "23.11";
    };
  };
}
