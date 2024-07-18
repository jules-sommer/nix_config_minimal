{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    types
    mkMerge
    enabled
    mkOpt
    mkListOf
    mkBoolOpt
    ;

  cfg = config.xeta.networking;
in
{
  options.xeta.networking = {
    enable = mkEnableOption "enable networking.";
    tcp_bbr = {
      enable = mkEnableOption "Enable networking tcp_bbr";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      mtr = enabled;
      wireshark = enabled;
    };

    environment.systemPackages = with pkgs; [
      nmap
      lurk
      tcpdump
      strace
      strace-analyzer
      netcat
      dnstracer
      wireshark
      tshark
      blahaj
      networkmanagerapplet
      termshark
    ];

    # Enable networking
    networking.networkmanager.enable = true;

    # Fixes an issue that normally causes nixos-rebuild to fail.
    # https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;

    # NETWORKING TWEAKS
    # (source: https://github.com/nh2/nixos-configs/blob/master/configuration.nix)

    # Hibernation with ZFS is unsafe; thus disable it.
    # This is likely the case even if the swap is put on a non-ZFS partition,
    # because the ZFS code paths do not handle being hibernated properly.
    # See:
    # * https://nixos.wiki/wiki/ZFS#Known_issues
    # * https://github.com/openzfs/zfs/issues/12842
    # * https://github.com/openzfs/zfs/issues/12843
    boot.kernelParams = [ "nohibernate" ];

    # Enable BBR congestion control
    boot.kernelModules = [ "tcp_bbr" ];
    boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
    boot.kernel.sysctl."net.core.default_qdisc" = "fq"; # see https://news.ycombinator.com/item?id=14814530

    # Increase TCP window sizes for high-bandwidth WAN connections, assuming
    # 10 GBit/s Internet over 200ms latency as worst case.
    #
    # Choice of value:
    #     BPP         = 10000 MBit/s / 8 Bit/Byte * 0.2 s = 250 MB
    #     Buffer size = BPP * 4 (for BBR)                 = 1 GB
    # Explanation:
    # * According to http://ce.sc.edu/cyberinfra/workshops/Material/NTP/Lab%208.pdf
    #   and other sources, "Linux assumes that half of the send/receive TCP buffers
    #   are used for internal structures", so the "administrator must configure
    #   the buffer size equals to twice" (2x) the BPP.
    # * The article's section 1.3 explains that with moderate to high packet loss
    #   while using BBR congestion control, the factor to choose is 4x.
    #
    # Note that the `tcp` options override the `core` options unless `SO_RCVBUF`
    # is set manually, see:
    # * https://stackoverflow.com/questions/31546835/tcp-receiving-window-size-higher-than-net-core-rmem-max
    # * https://bugzilla.kernel.org/show_bug.cgi?id=209327
    # There is an unanswered question in there about what happens if the `core`
    # option is larger than the `tcp` option; to avoid uncertainty, we set them
    # equally.
    boot.kernel.sysctl."net.core.wmem_max" = 1073741824; # 1 GiB
    boot.kernel.sysctl."net.core.rmem_max" = 1073741824; # 1 GiB
    boot.kernel.sysctl."net.ipv4.tcp_rmem" = "4096 87380 1073741824"; # 1 GiB max
    boot.kernel.sysctl."net.ipv4.tcp_wmem" = "4096 87380 1073741824"; # 1 GiB max
    # We do not need to adjust `net.ipv4.tcp_mem` (which limits the total
    # system-wide amount of memory to use for TCP, counted in pages) because
    # the kernel sets that to a high default of ~9% of system memory, see:
    # * https://github.com/torvalds/linux/blob/a1d21081a60dfb7fddf4a38b66d9cef603b317a9/net/ipv4/tcp.c#L4116

    time.timeZone = "America/Toronto";
    i18n.defaultLocale = "en_CA.UTF-8";
  };
}
