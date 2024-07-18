{ lib, inputs, ... }:
let
  inherit (lib) types;
in
rec {
  ###
  ### getPackage input: system:
  ### Takes an input that has a 'packages' attribute and with the provided system, returns
  ### the package(s) for that system that the input flake outputs.
  ###
  ### Example:
  ### ```nix
  ###   getPackage inputs.hyprland ${pkgs.system}
  ### ```
  getPackage =
    {
      input,
      system ? "x86_64-linux",
      name ? null,
    }:
    let
      attrNames = builtins.attrNames input.packages.${system};
    in
    assert lib.assertMsg (builtins.isAttrs input) "getPackage: input is not an attribute set";
    assert lib.assertMsg (builtins.hasAttr "packages" input)
      "getPackage: input does not have a 'packages' attribute";
    assert lib.assertMsg (builtins.hasAttr system (
      input.packages
    )) "getPackage: input does not have a 'packages.${system}' attribute";
    assert lib.assertMsg ((builtins.attrNames input.packages.${system}) != [ ])
      "getPackage: input.packages.${system} is empty, this flake input probably doesn't output any packages for the provided system of '${system}'.";
    if (name != null) then
      assert lib.assertMsg (
        builtins.typeOf (name) == "string" && name != ""
      ) "getPackage: name is null or not of type string";
      assert lib.assertMsg (builtins.hasAttr name (
        input.packages.${system}
      )) "getPackage: input.packages.${system} does not have a package named '${name}'";
      if (builtins.elem name attrNames) then builtins.getAttr name input.packages.${system} else null
    else
      builtins.map (x: input.packages.${system}.${x}) attrNames;

  ### Namespaced lib functions
  xeta = {
    systems = rec {
      supported = {
        x86_64-linux = "x86_64-linux";
        aarch64-linux = "aarch64-linux";
      };
      getNamesList = builtins.attrNames supported;
    };
  };

  ## Create a NixOS module option, with an optional description.
  ##
  ## Usage without description:
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default"
  ## ```
  ##
  ## Usage with description:
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> Optional String -> mkOption
  mkOpt =
    type: default: description:
    lib.mkOption { inherit type default description; };

  ## Create a NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;


  ## Create a boolean NixOS module option.
  ##
  ## ```nix
  ## lib.mkBoolOpt true "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt = mkOpt types.bool;

  ## Create a boolean NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkBoolOpt true
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt' = mkOpt' types.bool;

  # Checks if a path exists on the filesystem.
  #
  # ```nix
  # lib.pathExists "/etc/passwd"
  # ```
  #
  #@ String -> Bool
  pathExists = path: builtins.pathExists path;

  # Create a NixOS module option that allows user to pass a list of packages.
  #
  # ```nix
  # lib.mkListOf nixpkgs.lib.types.package (with nixpkgs; [git vim])
  # ```
  #
  #@ Type -> Any -> String
  mkListOf =
    type: default: description:
    lib.mkOption {
      inherit default description;
      type = lib.types.listOf type;
    };

  # This function takes an attribute set and formats it into a string,
  # with optional prefix and suffix for each attribute.
  # Each attribute is represented as a line in the string, in the format "prefix name=value suffix".
  #
  # Example:
  # If the attribute set is { a = 1; b = "text"; }, and prefix is "export ", and no suffix is provided,
  # the output will be:
  # "export A=1
  #  export B=text"
  #
  # Args:
  #   attrSet: The attribute set to format.
  #   separator: (optional) A string to separate each line.
  #   prefix: (optional) A string to prepend to each line.
  #   suffix: (optional) A string to append to each line.
  #
  # Returns:
  #   A string representing the formatted attribute set.
  serializeAttrSetToStr =
    {
      attrSet,
      separator ? "\n",
      prefix ? "",
      suffix ? "",
    }:
    with builtins;
    concatStringsSep separator (
      map (name: "${prefix}${name}=${attrSet.${name}}${suffix}") (attrNames attrSet)
    );

  # Helper function to convert string to uppercase
  stringToUpper =
    s:
    let
      lowercase = "abcdefghijklmnopqrstuvwxyz";
      uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    in
    lib.foldl' (
      acc: c:
      let
        pos = lib.stringPosition (x: x == c) lowercase;
      in
      acc + (if pos == null then lib.toString c else lib.substring (pos) (1) uppercase)
    ) "" s;

  ## Maps a list of strings to a single whitespace delimited string.
  ##
  ## ```nix
  ## lib.joinStrings ["a" "b" "c"]
  ## ```
  ##
  #@ List String -> String
  joinStrings = strings: builtins.concatStringsSep " " strings;

  enabled = {
    ## Quickly enable an option.
    ##
    ## ```nix
    ## services.nginx = enabled;
    ## ```
    ##
    #@ true
    enable = true;
  };

  disabled = {
    ## Quickly disable an option.
    ##
    ## ```nix
    ## services.nginx = enabled;
    ## ```
    ##
    #@ false
    enable = false;
  };
}
