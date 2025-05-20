{
  lib,
  buildNpmPackage,
  fetchzip,
}:
buildNpmPackage rec {
  pname = "claude-code";
  version = "0.2.122";

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-9w1wjuOTSphEfgKfNJhDFiTKuIJqfV6Bz4XEYXMIaGE=";
  };

  npmDepsHash = "sha256-ail4oHij4UbFdh6L1GgyaXI4pUie0O6dMFThSy6D7iE=Z";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  AUTHORIZED = "1";

  # `claude-code` tries to auto-update by default, this disables that functionality.
  # https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview#environment-variables
  postInstall = ''
    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1
  '';

  passthru.updateScript = ./update.sh;
}
