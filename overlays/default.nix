final: prev: {
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
