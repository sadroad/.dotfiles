final: prev: {
  helium = final.callPackage ../pkgs/helium/default.nix {};

  winboat =
    (import (builtins.fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/c5ae371f1a6a7fd27823bc500d9390b38c05fa55.tar.gz";
      sha256 = "sha256:18g0f8cb9m8mxnz9cf48sks0hib79b282iajl2nysyszph993yp0";
    }) {system = prev.stdenv.hostPlatform.system;}).winboat;

  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    postPatch =
      (oldAttrs.postPatch or "")
      + ''
        mkdir -p static
        rm -f static/splash.webp
        cp ${../assets/splash.webp} static/splash.webp
      '';
  });
}
