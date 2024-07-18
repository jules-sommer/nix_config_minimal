{ channels, ... }:

final: prev: { inherit (channels.master) electron-unwrapped obsidian bitwarden-desktop; }
