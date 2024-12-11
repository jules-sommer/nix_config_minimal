{ pkgs, ... }:
pkgs.fetchFromGitHub {
  owner = "catppuccin";
  repo = "starship";
  rev = "e99ba6b";
  hash = "sha256-KzXO4dqpufxTew064ZLp3zKIXBwbF8Bi+I0Xa63j/lI=";
}
