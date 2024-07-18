{ channels, inputs, ... }:
let
  zig-overlay = inputs.zig-overlay;
  zls = inputs.zls;
in
(final: prev: {
  zig = zig-overlay.packages.${prev.system}.master;
  zls = zls.packages.${prev.system}.zls;
})
