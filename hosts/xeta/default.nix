{
  host,
  users,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./system
  ];
  config = {
    system.stateVersion = mkDefault host.stateVersion;
    home-manager = {
      sharedModules = [
        ./home
      ];
    };
  };
}
