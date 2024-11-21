{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.xeta.development;

in
{
  imports = [
    ./rust
    ./go
    ./ocaml
    ./typescript
    ./zig
    ./nix
    ./odin
    ./clang
    ./python
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
    python = {
      enable = mkEnableOption "Enable Python configuration.";
    };
    odin = {
      enable = mkEnableOption "Odin lang support";
    };
    clang = {
      enable = mkEnableOption "Enable C configuration.";
    };
    # Non-language related extras, i.e CLI tools and system utilities.
    extras = {
      cli = mkOpt (types.nullOr (
        types.listOf types.package
      )) null "Additional CLI tools to install for development.";
    };
  };

  config = {
    programs.git = {
      enable = true;
      lfs.enable = true;
      config = {
        init = {
          defaultBranch = "main";
        };
        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
        };
      };
    };

    services.mysql = {
      enable = true;
      package = pkgs.mariadb_114;
      ensureUsers = [
        {
          name = "jules";
          ensurePermissions = {
            "scimag.*" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [
        "nextcloud"
        "matomo"
      ];
      initialDatabases = [
        {
          name = "scimag";
          schema = "/home/jules/015_articles-&-research/020_dois/scimag_2020-05-30.sql";
        }
      ];
    };

    # TODO: organize this stuff better
    environment.systemPackages = with pkgs; [
      # docs and man pages
      manix
      man
      man-pages
      man-pages-posix

      # filesystem
      joshuto

      # debugging
      rr
      gdb
      cgdb
      gf
      gdbgui
      valgrind
      rr
      tracy

      # clipboard
      wl-clipboard
      wl-clip-persist
      git
      flyctl
      lazygit
      just
      graphite-cli
      gh
      fastfetch
      blahaj
      nurl
      p7zip
      gitoxide
      ripgrep
      scriptisto
      fd
      dig
      bat
      jq
      nixfmt-rfc-style
      nix-index
      nix-prefetch-git
      nix-output-monitor
      flake-checker
      starship
      zoxide
      broot
      busybox
      jujutsu
      nil
      unzip
      ripunzip
      ripgrep-all
      zip
      gzip
      jql
      jq-lsp
    ];
  };
}
