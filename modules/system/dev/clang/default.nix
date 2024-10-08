{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.xeta.development.clang;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tinycc
      clang_19
      clangStdenv
      gcc14Stdenv
      arocc
      aroccStdenv
      cmake
      gcc14
      lldb_19
      clang-tools
    ];
  };
}
