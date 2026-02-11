inputs: final: prev:
let
  pinnedPkgs = import inputs.nixpkgs-vesktop {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  helium = final.callPackage ../pkgs/helium { };

  vesktop = pinnedPkgs.vesktop.overrideAttrs (oldAttrs: {
    postPatch = ''
      ${oldAttrs.postPatch or ""}
      mkdir -p static
      rm -f static/splash.webp
      cp ${../assets/splash.webp} static/splash.webp
    '';
  });
}
