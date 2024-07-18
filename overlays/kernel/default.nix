{ channels, ... }:
(_: prev: {
  inherit (channels.master) linuxPackages_latest;
  prev.linuxPackagesFor =
    kernel: (prev.linuxPackagesFor kernel).extend (_: _: { ati_drivers_x11 = null; });
})
