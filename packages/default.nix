{
  pkgs,
  lib,
}:
let
  inherit (lib) filterAttrs mapAttrs hasAttr;
  inherit (builtins) readDir;
  packages = mapAttrs (k: v: import ./${k}/default.nix { inherit pkgs lib; }) (
    filterAttrs (k: v: v == "directory") (readDir ./.)
  );
in
packages
