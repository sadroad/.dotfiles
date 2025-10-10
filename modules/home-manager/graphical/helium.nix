{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "helium";
  version = "0.5.3.1";

  src = let
    inherit (finalAttrs) version;
  in
    {
      aarch64-darwin = fetchurl {
        name = "helium_${version}_arm64-macos.dmg";
        url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
        hash = "sha256-UGbsKjq/KDZF4VIAMFf6QdOtSR+/YbTAMp1KYeFFhls=";
      };
    }
    .${
      stdenvNoCC.system
    } or (throw "helium: ${stdenvNoCC.system} is unsupported.");

  nativeBuildInputs = [_7zz];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/Helium.app
    cp -R . $out/Applications/Helium.app

    runHook postInstall
  '';
})
