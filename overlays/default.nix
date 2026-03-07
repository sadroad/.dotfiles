inputs: final: prev: {
  helium = final.callPackage ../pkgs/helium { };
  codex = inputs.codex.packages.${prev.stdenv.hostPlatform.system}.default;
  handy = inputs.handy.packages.${prev.stdenv.hostPlatform.system}.default;
  jj-starship = inputs.jj-starship.packages.${prev.stdenv.hostPlatform.system}.jj-starship;
  nh = inputs.nh.packages.${prev.stdenv.hostPlatform.system}.nh;
  nix-alien = inputs.nix-alien.packages.${prev.stdenv.hostPlatform.system}.default;
  pom = inputs.pom.packages.${prev.stdenv.hostPlatform.system}.default;
  wakatime-ls = inputs.wakatime-ls.packages.${prev.stdenv.hostPlatform.system}.default;

  vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
    postPatch = ''
      ${oldAttrs.postPatch or ""}
      mkdir -p static
      rm -f static/splash.webp
      cp ${../assets/splash.webp} static/splash.webp
    '';
  });
}
