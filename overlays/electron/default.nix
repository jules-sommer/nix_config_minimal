{ channels, ... }:

final: prev: { inherit (channels.stable) electrum-ltc electrum; }
