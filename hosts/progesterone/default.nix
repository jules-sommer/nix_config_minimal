{
  imports = [
    ./system
  ];
  config = {
    home-manager = {
      sharedModules = [
        ./home
      ];
    };
  };
}
