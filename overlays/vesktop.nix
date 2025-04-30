{inputs, ...}: final: prev: {
  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    postPatch = ''
      echo "Applying custom shiggy.gif patch to Vesktop"
      mkdir -p static
      rm -f static/shiggy.gif
      # Reference the asset from the correct relative path
      cp ${../assets/shiggy.gif} static/shiggy.gif
      echo "Successfully replaced static/shiggy.gif"
    '';
  });
}
