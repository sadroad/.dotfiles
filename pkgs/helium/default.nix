{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  _7zz,
  _experimental-update-script-combinators,
  nix-update-script,
  widevine-cdm ? null,
  enableWideVine ? false,
}:
let
  pname = "helium";
  version = "0.10.1.1";
  inherit (stdenv.hostPlatform) system;
  linuxRepo = "https://github.com/imputnet/helium-linux";

  sourceMap = {
    aarch64-darwin = fetchurl {
      name = "helium_${version}_arm64-macos.dmg";
      url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
      hash = "sha256-f4t75ub1UWYIhwJDG+5USqPwGhqNCMuvyOA1Jy5pg2s=";
    };
    x86_64-linux = fetchurl {
      url = "${linuxRepo}/releases/download/${version}/helium-${version}-x86_64.AppImage";
      hash = "sha256-N5gdWuxOrIudJx/4nYo4/SKSxakpTFvL4zzByv6Cnug=";
    };
    aarch64-linux = fetchurl {
      url = "${linuxRepo}/releases/download/${version}/helium-${version}-arm64.AppImage";
      hash = "sha256-BvU0bHtJMd6e09HY+9Vhycr3J0O2hunRJCHXpzKF8lk=";
    };
  };

  baseMeta = {
    description = "Private, fast, and honest web browser based on Chromium";
    homepage = "https://github.com/imputnet/helium-chromium";
  };

  linuxBuilder =
    assert !enableWideVine || widevine-cdm != null;
    appimageTools.wrapAppImage rec {
      inherit pname version;

      src = appimageTools.extract {
        inherit pname version;

        src = sourceMap.${system} or (throw "Unsupported system: ${system}");

        postExtract = lib.optionalString enableWideVine ''
          mkdir -p $out/opt/helium/WidevineCdm
          cp -a ${widevine-cdm}/share/google/chrome/WidevineCdm/* $out/opt/helium/WidevineCdm/
        '';
      };

      passthru.updateScript = _experimental-update-script-combinators.sequence [
        (nix-update-script {
          attrPath = "helium";
          extraArgs = [
            "--system"
            "x86_64-linux"
            "--flake"
            "--url"
            linuxRepo
          ];
        })
        (nix-update-script {
          attrPath = "helium";
          extraArgs = [
            "--system"
            "aarch64-linux"
            "--version"
            "skip"
            "--flake"
            "--url"
            linuxRepo
          ];
        })
      ];

      extraInstallCommands = ''
        mkdir -p "$out/share/applications"
        mkdir -p "$out/share/lib/helium"
        cp -r ${src}/opt/helium/locales "$out/share/lib/helium"
        cp -r ${src}/usr/share/* "$out/share"
        cp "${src}/${pname}.desktop" "$out/share/applications/"
        substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=helium %U' 'Exec=${meta.mainProgram} %U'
      '';

      meta = baseMeta // {
        changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        license = if enableWideVine then lib.licenses.unfree else lib.licenses.gpl3;
        mainProgram = "helium";
      };
    };

  builders = {
    "aarch64-darwin" = stdenvNoCC.mkDerivation {
      inherit pname version;

      src = sourceMap.aarch64-darwin;

      nativeBuildInputs = [ _7zz ];

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications/Helium.app
        cp -R . $out/Applications/Helium.app
        runHook postInstall
      '';

      meta = baseMeta // {
        description = "${baseMeta.description} (macOS build)";
        license = lib.licenses.gpl3;
        platforms = [ "aarch64-darwin" ];
        mainProgram = "Helium.app";
      };
    };

    x86_64-linux = linuxBuilder;
    aarch64-linux = linuxBuilder;
  };
in
builders.${system} or (throw "helium: ${system} is unsupported.")
