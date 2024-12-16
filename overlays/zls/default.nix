{ inputs, ... }:
let
  inherit (inputs) zls;
in
_: prev: {
  inherit (zls.packages.${prev.system}) zls;
}
