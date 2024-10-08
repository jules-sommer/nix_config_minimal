{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixvim
    youtube-tui
    gparted
  ];
}
