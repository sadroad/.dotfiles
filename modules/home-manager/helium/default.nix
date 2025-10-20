{
  newScope,
  config,
  stdenv,
  makeWrapper,
  buildPackages,
  ed,
  gnugrep,
  coreutils,
  xdg-utils,
  glib,
  gtk3,
  gtk4,
  adwaita-icon-theme,
  gsettings-desktop-schemas,
  gn,
  fetchgit,
  libva,
  pipewire,
  wayland,
  runCommand,
  lib,
  libkrb5,
  widevine-cdm,
  electron-source, # for warnObsoleteVersionConditional
  # package customization
  # Note: enable* flags should not require full rebuilds (i.e. only affect the wrapper)
  upstream-info ? (lib.importJSON ./info.json).${variant},
  proprietaryCodecs ? true,
  enableWideVine ? false,
  variant ? "chromium", # chromium, ungoogled, helium
  cupsSupport ? true,
  pulseSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
  commandLineArgs ? "",
  pkgsBuildBuild,
  pkgs,
}: let
  stdenv = pkgs.rustc.llvmPackages.stdenv;

  # Helper functions for changes that depend on specific versions:
  warnObsoleteVersionConditional = min-version: result: let
    min-supported-version = (lib.head (lib.attrValues electron-source)).unwrapped.info.chromium.version;
    # Warning can be toggled by changing the value of enabled:
    enabled = false;
  in
    lib.warnIf (enabled && lib.versionAtLeast min-supported-version min-version)
    "chromium: min-supported-version ${min-supported-version} is newer than a conditional bounded at ${min-version}. You can safely delete it."
    result;
  chromiumVersionAtLeast = min-version: let
    result = lib.versionAtLeast upstream-info.version min-version;
  in
    warnObsoleteVersionConditional min-version result;
  versionRange = min-version: upto-version: let
    inherit (upstream-info) version;
    result = lib.versionAtLeast version min-version && lib.versionOlder version upto-version;
  in
    warnObsoleteVersionConditional upto-version result;

  callPackage = newScope chromium;

  chromium = rec {
    inherit stdenv upstream-info;

    mkChromiumDerivation = callPackage ./common.nix {
      inherit chromiumVersionAtLeast versionRange;
      inherit
        proprietaryCodecs
        cupsSupport
        pulseSupport
        variant
        ;
      gnChromium = buildPackages.gn.override upstream-info.deps.gn;
    };

    browser = callPackage ./browser.nix {
      inherit chromiumVersionAtLeast enableWideVine variant;
    };

    # so is helium.
    helium = pkgsBuildBuild.callPackage ./variants/helium {};
  };

  sandboxExecutableName = chromium.browser.passthru.sandboxExecutableName;

  # We want users to be able to enableWideVine without rebuilding all of
  # chromium, so we have a separate derivation here that copies chromium
  # and adds the unfree WidevineCdm.
  chromiumWV = let
    browser = chromium.browser;
  in
    if enableWideVine
    then
      runCommand (browser.name + "-wv") {version = browser.version;} ''
        mkdir -p $out
        cp -a ${browser}/* $out/
        chmod u+w $out/libexec/chromium
        cp -a ${widevine-cdm}/share/google/chrome/WidevineCdm $out/libexec/chromium/
      ''
    else browser;
in
  stdenv.mkDerivation {
    inherit ((import ./variants/meta.nix lib).${variant}) pname;
    inherit (chromium.browser) version;

    nativeBuildInputs = [
      makeWrapper
      ed
    ];

    buildInputs = [
      # needed for GSETTINGS_SCHEMAS_PATH
      gsettings-desktop-schemas
      glib
      gtk3
      gtk4

      # needed for XDG_ICON_DIRS
      adwaita-icon-theme

      # Needed for kerberos at runtime
      libkrb5
    ];

    outputs = [
      "out"
      "sandbox"
    ];

    buildCommand = let
      packageName = chromium.browser.packageName;
      mainProgram = chromium.browser.meta.mainProgram;
      browserName = chromium.browser.passthru.browserName;
      browserBinary = "${chromiumWV}/libexec/${packageName}/${packageName}";
      libPath = lib.makeLibraryPath [
        libva
        pipewire
        wayland
        gtk3
        gtk4
        libkrb5
      ];
    in
      ''
        mkdir -p "$out/bin"

        makeWrapper "${browserBinary}" "$out/bin/${mainProgram}" \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
          --add-flags ${lib.escapeShellArg commandLineArgs}

        ed -v -s "$out/bin/${mainProgram}" << EOF
        2i

        if [ -x "/run/wrappers/bin/${sandboxExecutableName}" ]
        then
          export CHROME_DEVEL_SANDBOX="/run/wrappers/bin/${sandboxExecutableName}"
        else
          export CHROME_DEVEL_SANDBOX="$sandbox/bin/${sandboxExecutableName}"
        fi

        # Make generated desktop shortcuts have a valid executable name.
        export CHROME_WRAPPER='${mainProgram}'

      ''
      + lib.optionalString (libPath != "") ''
        # To avoid loading .so files from cwd, LD_LIBRARY_PATH here must not
        # contain an empty section before or after a colon.
        export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH\''${LD_LIBRARY_PATH:+:}${libPath}"
      ''
      + ''

        # libredirect causes chromium to deadlock on startup
        export LD_PRELOAD="\$(echo -n "\$LD_PRELOAD" | ${coreutils}/bin/tr ':' '\n' | ${gnugrep}/bin/grep -v /lib/libredirect\\\\.so$ | ${coreutils}/bin/tr '\n' ':')"

        export XDG_DATA_DIRS=$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH\''${XDG_DATA_DIRS:+:}\$XDG_DATA_DIRS

      ''
      + lib.optionalString (!xdg-utils.meta.broken) ''
        # Mainly for xdg-open but also other xdg-* tools (this is only a fallback; \$PATH is suffixed so that other implementations can be used):
        export PATH="\$PATH\''${PATH:+:}${xdg-utils}/bin"
      ''
      + ''

        .
        w
        EOF

        ln -sv "${chromium.browser.sandbox}" "$sandbox"

        ${lib.optionalString (browserName != mainProgram) ''
          ln -s "$out/bin/${mainProgram}" "$out/bin/${browserName}"
        ''}

        mkdir -p "$out/share"
        for f in '${chromium.browser}'/share/*; do # hello emacs */
          ln -s -t "$out/share/" "$f"
        done
      '';

    inherit (chromium.browser) packageName;
    meta = chromium.browser.meta;
    passthru = {
      inherit (chromium) upstream-info browser;
      mkDerivation = chromium.mkChromiumDerivation;
      inherit sandboxExecutableName;
    };
  }
