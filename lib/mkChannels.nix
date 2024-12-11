{ system, ... }:
let
  mkChannel =
    let
      # Extend the channel's lib with local extensions
      extendedLib = pkgs.lib.extend (final: prev: import local_lib { lib = prev; });
    in
    {
      inherit pkgs;
      lib = extendedLib;
    };

  channelsAttr = lib.genAttrs enabledChannels makeChannel;

  channels = channelsAttr // {
    default = channelsAttr.${defaultChannel};
  };
in
channels
