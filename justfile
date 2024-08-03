show:
  nix flake show

check:
  nix flake check

repl:
  #!/usr/bin/env nix-shell
  #! nix-shell -i nu -p tinycc
  nix repl --expr $"builtins.getFlake \"(pwd)\""

extern-build scope="system" action="switch" out="xeta":
  #!/usr/bin/env nix-shell
  #! nix-shell -i nu -p tinycc
  let valid_system_scopes = ["system" "sys" "nixos" ];
  let valid_home_scopes = ["home" "home-mabuildnager" "hm" ];

  let action = "{{action}}";
  let out = "{{out}}";

  let scope = if "{{scope}}" in valid_system_scopes {
    "system"
  } else if "{{scope}}" in valid_home_scopes {
    "home"
  } else if "{{scope}}" == "all" {
    "all"
  } else {
    print "Scope must be either 'system' or 'home'... exiting."
    exit 1
  };

  print $"(ansi magenta)Running (ansi cyan_bold)`($action)`(ansi magenta) on (ansi cyan_bold)`($out)#($scope)`(ansi magenta)...(ansi reset)"

  mut has_error: bool = false;

  if $scope in ["system" "all"] {
    if $action in ["switch"  "boot"  "test" "build" "dry-build"] {
      let result = try {
        run-external "sudo" "nixos-rebuild" $action "--flake" $".#($out)" | complete
      } catch { |error|
        print $error;
      }
      print $result;
    } else {
      print $"(ansi red_bold)Action of `($action)` is not a valid action... exiting.(ansi reset)"
      exit 1
    }
  }

  if $scope in ["home" "all"] {
    if $action in ["switch" "build" "test" ] {
      let result = try {
        run-external "home-manager" ($action) "--flake" $".#($out)" | complete
      } catch { |error|
        print $error;
      }

      print $result;
    } else {
      print $"(ansi red_bold)Action of `($action)` is not a valid action... exiting.(ansi reset)"
      exit 1
    }
  }

  if $scope not-in ["system" "home" "all"] {
    print $"(ansi red_bold)Scope of `($scope)` is not a valid scope... exiting.(ansi reset)"
    exit 1
  }
