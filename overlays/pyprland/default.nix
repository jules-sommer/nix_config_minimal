{ pyprland, ... }: (final: prev: { pyprland = pyprland.outputs.packages.${prev.system}.pyprland; })
