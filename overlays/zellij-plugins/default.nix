{ self, inputs, ... }:
let
  zjstatus = inputs.zjstatus;
  zjharpoon = inputs.zjharpoon;
  zjmonocle = inputs.zjmonocle;
in
(final: prev: {
  zjstatus = zjstatus.packages.${prev.system}.default;
  zjmonocle = zjmonocle.packages.${prev.system}.default;
  zjharpoon = zjharpoon.packages.${prev.system}.default;
})
