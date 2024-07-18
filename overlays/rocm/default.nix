{ channels, ... }:

final: prev: { inherit (channels.stable) rocmPackages; }
