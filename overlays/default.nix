inputs: final: prev:
let
  rust-bin = inputs.rust-overlay.lib.mkRustBin { } final;
in
{
  helium = final.callPackage ../pkgs/helium { };
  pom = final.callPackage ../pkgs/pom { inherit rust-bin; };

  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    postPatch = ''
      ${oldAttrs.postPatch or ""}
      mkdir -p static
      rm -f static/splash.webp
      cp ${../assets/splash.webp} static/splash.webp
    '';
  });
}
