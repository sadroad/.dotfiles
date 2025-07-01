{
  lib,
  stdenv,
  bun,
  fetchFromGitHub,
  go,
  nix-update-script,
  makeBinaryWrapper,
  testers,
}: let
  version = "0.1.170";
  src = fetchFromGitHub {
    owner = "sst";
    repo = "opencode";
    tag = "v${version}";
    hash = "sha256-pHwIHxKMW2A2trV4Rzk4jLkPChLMOBWiPLniBms1qP0=";
  };

  opencode-node-modules-hash = {
    "aarch64-darwin" = "sha256-+VAGsQf2oXffsrv2GDcOItbfCmjIu5QfaaZ9PtE4K04=";
    "aarch64-linux" = "sha256-t7dcyPsWeqYJv4/DPP15bvVurVPGCXWXVPUfpk1+l1Q=";
    "x86_64-darwin" = "sha256-qYljdz4iyl3aZBhVU+uIVx4ZsvY9ubTTLNxJ94TUkBo=";
    "x86_64-linux" = "sha256-TYjcA7MTfOKkvTwGSK1SotMDIH9xag79dikf6hMF8us=";
  };
  node_modules = stdenv.mkDerivation {
    name = "opencode-${version}-node-modules";
    inherit version src;

    impureEnvVars =
      lib.fetchers.proxyImpureEnvVars
      ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

    nativeBuildInputs = [bun];

    dontConfigure = true;

    buildPhase = ''
      bun install --no-cache --no-progress --frozen-lockfile  --filter=opencode
    '';

    installPhase = ''
      mkdir -p $out/node_modules

      cp -R ./node_modules $out
    '';

    # Required else we get errors that our fixed-output derivation references store paths
    dontFixup = true;

    outputHash = opencode-node-modules-hash.${stdenv.hostPlatform.system};
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "opencode";
    inherit version src;

    nativeBuildInputs = [makeBinaryWrapper];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin

      ln -s ${node_modules}/node_modules $out
      cp -R ./* $out

      # bun is referenced naked in the package.json generated script
      makeBinaryWrapper ${bun}/bin/bun $out/bin/opencode \
        --prefix PATH : ${
        lib.makeBinPath [
          bun
          go
        ]
      } \
        --add-flags "run --prefer-offline --no-install --cwd $out ./packages/opencode/src/index.ts"

      runHook postInstall
    '';

    passthru = {
      tests.version = testers.testVersion {package = finalAttrs.finalPackage;};
      updateScript = nix-update-script {};
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
