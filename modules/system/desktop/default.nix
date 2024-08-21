{ ... }:
{
  imports = [
    ./hyprland
    ./plasma6
  ];

  config = {
    # enable xserver for any desktop env that needs it
    services.xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 30;
      autorun = true;
      xkb = {
        layout = "us";
        options = "eurosign:e,caps:escape";
      };
    };
  };
}
