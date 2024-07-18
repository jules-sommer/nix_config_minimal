{ channels, ... }:

(final: prev: {
  # Override for using Vscode Insiders edition, basically nightly/unstable release instead
  vscode-with-extensions =
    (prev.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
      src = (builtins.fetchTarball {
        url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
        sha256 = "03gkp5lchgjq2636rxniw0nw3q6i630lgjrg9vli1azb5akhlyr7";
      });
      version = "latest";
    });
})
