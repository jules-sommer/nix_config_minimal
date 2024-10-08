{ ... }:
{
  imports = [ ./tcp-bbr/default.nix ];

  config = {
    # Enable systemd-networkd
    networking.useNetworkd = true;

    # Configure networkd-specific settings
    systemd.network = {
      enable = true;
      networks = {
        # "10-wired" = {
        #   matchConfig.Name = "enp14s0";
        #   networkConfig.DHCP = "yes";
        # };
        "20-wireless" = {
          matchConfig.Name = "wlp15s0";
          networkConfig.DHCP = "yes";
        };
      };
    };

    # Optionally, configure DNS settings if systemd-resolved is not used
    networking.nameservers = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };
}
