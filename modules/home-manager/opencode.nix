{
  lib,
  stdenvNoCC,
  buildGoModule,
  bun,
  fetchFromGitHub,
  models-dev,
  nix-update-script,
  testers,
  writableTmpDirAsHomeHook,
}: let
  opencode-node-modules-hash = {
    "aarch64-darwin" = "sha256-BZ7rVCcBMTbyYWx5VEfFQo3UguthDgxhIjZ+6T3jrIM=";
    "aarch64-linux" = "";
    "x86_64-darwin" = "";
    "x86_64-linux" = "";
  };
  bun-target = {
    "aarch64-darwin" = "bun-darwin-arm64";
    "aarch64-linux" = "bun-linux-arm64";
    "x86_64-darwin" = "bun-darwin-x64";
    "x86_64-linux" = "bun-linux-x64";
  };
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "opencode";
    version = "0.5.18";
    src = fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${finalAttrs.version}";
      hash = "sha256-vXIdh1A7gM9aweZriHAq3dk1gI69yx9T2WlB/+v5Iqs=";
    };

    tui = buildGoModule {
      pname = "opencode-tui";
      inherit (finalAttrs) version src;

      modRoot = "packages/tui";

      vendorHash = "sha256-78MfWF0HSeLFLGDr1Zh74XeyY71zUmmazgG2MnWPucw=";

      subPackages = ["cmd/opencode"];

      env.CGO_ENABLED = 0;

      ldflags = [
        "-s"
        "-X=main.Version=${finalAttrs.version}"
      ];

      installPhase = ''
        runHook preInstall

        install -Dm755 $GOPATH/bin/opencode $out/bin/tui

        runHook postInstall
      '';
    };

    node_modules = stdenvNoCC.mkDerivation {
      pname = "opencode-node_modules";
      inherit (finalAttrs) version src;

      impureEnvVars =
        lib.fetchers.proxyImpureEnvVars
        ++ [
          "GIT_PROXY_COMMAND"
          "SOCKS_SERVER"
        ];

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ];

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

         export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

         bun install \
           --filter=opencode \
           --force \
           --frozen-lockfile \
           --ignore-scripts \
           --no-progress \
           --production

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/node_modules
        cp -R ./node_modules $out

        runHook postInstall
      '';

      # Required else we get errors that our fixed-output derivation references store paths
      dontFixup = true;

      outputHash = opencode-node-modules-hash.${stdenvNoCC.hostPlatform.system};
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

    nativeBuildInputs = [
      bun
      models-dev
    ];

    configurePhase = ''
      runHook preConfigure

      cp -R ${finalAttrs.node_modules}/node_modules .

      runHook postConfigure
    '';

    env.MODELS_DEV_API_JSON = "${models-dev}/dist/api.json";

    buildPhase = ''
      runHook preBuild

      bun build \
        --define OPENCODE_TUI_PATH="'${finalAttrs.tui}/bin/tui'" \
        --define OPENCODE_VERSION="'${finalAttrs.version}'" \
        --define OPENCODE_DISABLE_AUTOUPDATE="false" \
        --compile \
        --target=${bun-target.${stdenvNoCC.hostPlatform.system}} \
        --outfile=opencode \
        ./packages/opencode/src/index.ts \

      runHook postBuild
    '';

    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 opencode $out/bin/opencode

      runHook postInstall
    '';

    passthru = {
      tests.version = testers.testVersion {
        package = finalAttrs.finalPackage;
        command = "HOME=$(mktemp -d) opencode --version";
        inherit (finalAttrs) version;
      };
      updateScript = nix-update-script {
        extraArgs = [
          "--subpackage"
          "tui"
          "--subpackage"
          "node_modules"
        ];
      };
    };

    meta = {
      description = "AI coding agent built for the terminal";
      longDescription = ''
        OpenCode is a terminal-based agent that can build anything.
        It combines a TypeScript/JavaScript core with a Go-based TUI
        to provide an interactive AI coding experience.
      '';
      homepage = "https://github.com/sst/opencode";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      maintainers = with lib.maintainers; [
        zestsystem
        delafthi
      ];
      mainProgram = "opencode";
    };
  })
