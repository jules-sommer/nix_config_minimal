{ pkgs, ... }:
{
  catppuccin-starship = import ./catppuccin-starship { inherit pkgs; };
}
