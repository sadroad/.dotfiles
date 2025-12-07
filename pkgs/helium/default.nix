{
  lib,
  stdenvNoCC,
  pkgs,
  fetchurl,
  _7zz,
}: let
  pname = "helium";
  version = "0.7.2.1";
  inherit (pkgs.stdenv.hostPlatform) system;

  hashes = {
    "aarch64-darwin" = "sha256-ppcz7JM6i2aNqimGrT9l+Eu41oirff0WV93wBI7PLYA=";
    "x86_64-linux" = "sha256-PwXgpmauBN6EXoZE6HnpgrisrO5a9VzQEDv3T2OsPnc=";
  };

  baseMeta = {
    description = "Private, fast, and honest web browser based on Chromium";
    homepage = "https://github.com/imputnet/helium-chromium";
    license = lib.licenses.gpl3;
  };

  builders = {
    "aarch64-darwin" = stdenvNoCC.mkDerivation {
      inherit pname version;

      src = fetchurl {
        name = "helium_${version}_arm64-macos.dmg";
        url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
        hash = hashes."aarch64-darwin";
      };

      nativeBuildInputs = [_7zz];

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications/Helium.app
        cp -R . $out/Applications/Helium.app
        runHook postInstall
      '';

      meta =
        baseMeta
        // {
          description = "${baseMeta.description} (macOS build)";
          platforms = ["aarch64-darwin"];
          mainProgram = "Helium.app";
        };
    };

    "x86_64-linux" = pkgs.appimageTools.wrapType2 rec {
      inherit pname version;

      src = fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
        hash = hashes."x86_64-linux";
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

      meta =
        baseMeta
        // {
          description = "${baseMeta.description} (Linux build)";
          changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
          platforms = ["x86_64-linux"];
          mainProgram = "helium";
        };
    };
  };
in
  builders.${system} or (throw "helium: ${system} is unsupported.")
