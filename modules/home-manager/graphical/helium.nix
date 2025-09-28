{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "helium";
  version = "0.4.12.1";

  src = let
    inherit (finalAttrs) version;
  in
    {
      aarch64-darwin = fetchurl {
        name = "helium_${version}_arm64-macos.dmg";
        url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
        hash = "";
      };
    }
    .${
      stdenvNoCC.system
    } or (throw "helium: ${stdenvNoCC.system} is unsupported.");

  nativeBuildInputs = [undmg];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/Helium.app
    cp -R . $out/Applications/Helium.app

    runHook postInstall
  '';
})
