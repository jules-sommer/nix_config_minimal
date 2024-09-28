{ ... }:
{
  imports = [
    ./hyprland
    ./plasma6
    ./river
  ];

  config = {
    # enable xserver for any desktop env that needs it
    qt = {
      enable = true;
      style = "breeze";
      platformTheme = "kde";
    };
    services = {
      xserver = {
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
  };
}
