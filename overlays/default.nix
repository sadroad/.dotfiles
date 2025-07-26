final: prev: {
  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    postPatch =
      (oldAttrs.postPatch or "")
      + ''
        mkdir -p static
        rm -f static/shiggy.gif
        cp ${../assets/shiggy.gif} static/shiggy.gif
      '';
  });
}
