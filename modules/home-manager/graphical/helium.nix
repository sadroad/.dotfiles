{
  lib,
  stdenvNoCC,
  pkgs,
  fetchurl,
  _7zz,
  ...
}: let
  pname = "helium";
  version = "0.5.8.1";
in
  if pkgs.stdenv.isDarwin
  then
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit pname version;

      src = let
        inherit (finalAttrs) version;
      in
        {
          aarch64-darwin = fetchurl {
            name = "helium_${version}_arm64-macos.dmg";
            url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
            hash = "sha256-ph3SQqIInSlZ9r6Px2jGABX0D+bCMeCwFB/8ieetXxs=";
          };
        }."${stdenvNoCC.hostPlatform.system}" or (throw "helium: ${stdenvNoCC.hostPlatform.system} is unsupported.");

      nativeBuildInputs = [_7zz];

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications/Helium.app
        cp -R . $out/Applications/Helium.app
        runHook postInstall
      '';

      meta = {
        description = "Private, fast, and honest web browser based on Chromium (macOS build)";
        homepage = "https://github.com/imputnet/helium-chromium";
        license = lib.licenses.gpl3;
        platforms = ["aarch64-darwin"];
        mainProgram = "Helium.app";
      };
    })
  else
    pkgs.appimageTools.wrapType2 rec {
      inherit pname version;

      src = let
        platformMap = {
          "x86_64-linux" = "x86_64";
          "aarch64-linux" = "arm64";
        };
        platform = platformMap.${pkgs.stdenv.hostPlatform.system};
        hashes = {
          "x86_64-linux" = "sha256-d8kwLEU6qgEgp7nlEwdfRevB1JrbEKHRe8+GhGpGUig=";
          "aarch64-linux" = "sha256-/ZnLJNS/WBcWjUXUfqylqJCVh8HUNlIrVQCrb/QoL2I=";
        };
        hash = hashes.${pkgs.stdenv.hostPlatform.system};
      in
        pkgs.fetchurl {
          url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${platform}.AppImage";
          inherit hash;
        };

      extraInstallCommands = let
        contents = pkgs.appimageTools.extractType2 {inherit pname version src;};
      in ''
        mkdir -p "$out/share/applications"
        mkdir -p "$out/share/lib/helium"
        cp -r ${contents}/opt/helium/locales "$out/share/lib/helium"
        cp -r ${contents}/usr/share/* "$out/share"
        cp "${contents}/${pname}.desktop" "$out/share/applications/"
        substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
      '';

      meta = {
        description = "Private, fast, and honest web browser based on Chromium (Linux build)";
        homepage = "https://github.com/imputnet/helium-chromium";
        changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
        license = lib.licenses.gpl3;
        platforms = ["x86_64-linux" "aarch64-linux"];
        mainProgram = "helium";
      };
    }
