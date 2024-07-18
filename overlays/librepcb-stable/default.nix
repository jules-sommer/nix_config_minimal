{ channels, ... }:

final: prev: {
  inherit (channels.stable) librepcb;
}
