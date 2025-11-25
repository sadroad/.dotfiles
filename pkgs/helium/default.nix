{
  lib,
  stdenvNoCC,
  pkgs,
  fetchurl,
  _7zz,
  ...
}: let
  pname = "helium";
  version = "0.6.7.1";
  inherit (pkgs.stdenv.hostPlatform) system;

  baseMeta = {
    description = "Private, fast, and honest web browser based on Chromium";
    homepage = "https://github.com/imputnet/helium-chromium";
    license = lib.licenses.gpl3;
  };

  builders = {
    "aarch64-darwin" = _:
      stdenvNoCC.mkDerivation {
        inherit pname version;

        src = fetchurl {
          name = "helium_${version}_arm64-macos.dmg";
          url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
          hash = "sha256-eU+A9U9eONushaR1cnOtHGw7qejsN0OswJ5hd7CIbow=";
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

    "x86_64-linux" = system':
      pkgs.appimageTools.wrapType2 rec {
        inherit pname version;

        src = let
          platformMap = {
            "x86_64-linux" = "x86_64";
          };
          platform =
            platformMap.${system'}
          or (throw "helium: ${system'} is unsupported for AppImage builds.");
          hashes = {
            "x86_64-linux" = "sha256-fZTBNhaDk5EeYcxZDJ83tweMZqtEhd7ws8AFUcHjFLs=";
          };
          hash =
            hashes.${system'}
          or (throw "helium: missing hash for ${system'}.");
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

        meta =
          baseMeta
          // {
            description = "${baseMeta.description} (Linux build)";
            changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
            platforms = ["x86_64-linux" "aarch64-linux"];
            mainProgram = "helium";
          };
      };
  };
in
  (builders.${system} or (throw "helium: ${system} is unsupported.")) system
