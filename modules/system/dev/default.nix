{
  lib,
  pkgs,
  config,
  inputs,
  system,
  ...
}:
let
  inherit (lib) mkOpt types mkEnableOption mkIf;
  cfg = config.xeta.development;
  anyLangEnabled = lib.any (
    lang:
    lib.attrByPath [
      lang
      "enable"
    ] false cfg
  ) (lib.attrNames cfg);

  cliUtilsEnabled = (cfg.extras.cli != null && lib.length cfg.extras.cli > 0); 
in
{
  imports = [
    ./rust/default.nix
    ./go/default.nix
    ./ocaml/default.nix
    ./typescript/default.nix
    ./zig/default.nix
  ];

  options.xeta.development = {
    rust = {
      enable = mkEnableOption "Enable Rust toolchain via/Fenix overlay.";
      profile = mkOpt (types.enum [
        "default"
        "minimal"
        "complete"
      ]) "complete" "Profile of Rust toolchain to use, must be one of: default, minimal, complete.";
    };
    ocaml = {
      enable = mkEnableOption "Enable OCaml support";
    };
    zig = {
      enable = mkEnableOption "Enable Zig support";
    };
    nix = {
      enable = mkEnableOption "Enable Nix toolchain..";
    };
    go = {
      enable = mkEnableOption "Enable Go configuration.";
    };
    typescript = {
      enable = mkEnableOption "Enable TypeScript configuration.";
      runtimes =
        mkOpt
          # option type
          (types.listOf types.enum [
            "nodejs"
            "deno"
          ])
          # default
          [
            "nodejs"
            "deno"
          ]
          # description
          "Runtimes to use for TypeScript.";
    };
    c = {
      enable = mkEnableOption "Enable C configuration.";
    };

    # Non-language related extras, i.e CLI tools and system utilities.
    extras = {
      cli = mkOpt (types.nullOr (types.listOf types.package)) null "Additional CLI tools to install for development.";   
    };
  };

  config = mkIf (cliUtilsEnabled) {
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wl-clip-persist
      git
      zed-editor
      lazygit
      just
      graphite-cli
      gh
      fastfetch
      blahaj
      nixd
      nurl
      p7zip
      gitoxide
      ripgrep
      scriptisto
      fd
      dig
      bat
      jq
      helix
      deploy-rs
      nixfmt-rfc-style
      nix-index
      nix-prefetch-git
      nix-output-monitor
      flake-checker
      starship
      zoxide
      broot
      nushell
      busybox
      jujutsu
      nil
      pzip
      jql
      jq-lsp
      apx
    ];
  };
}
