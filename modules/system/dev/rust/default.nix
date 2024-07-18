{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.development.rust;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.rust-bin.selectLatestNightlyWith (
        toolchain:
        toolchain.default.override {
          extensions = [
            "rust-src"
            "clippy"
            "rustfmt"
            "rustc"
            "cargo"
          ];
          targets = [ "x86_64-unknown-linux-gnu" ];
        }
      ))

      # (pkgs.fenix.complete.withComponents [
      #   "cargo"
      #   "clippy"
      #   "rust-src"
      #   "rustc"
      #   "rustfmt"
      # ])
      pkgs.vscode-extensions.rust-lang.rust-analyzer-nightly
      pkgs.rust-analyzer-nightly
    ];
  };
}
