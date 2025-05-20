{
  pkgs,
  lib,
  stdenvNoCC,
  themeConfig ? null,
}:
stdenvNoCC.mkDerivation rec {
  pname = "sddm-eucalyptus-drop";
  version = "2.0.0";

  src = pkgs.fetchFromGitLab {
    owner = "Matt.Jolly";
    repo = "sddm-eucalyptus-drop";
    rev = "v${version}";
    hash = "sha256-C3qB9hFUeuT5+Dos2zFj5SyQegnghpoFV9wHvE9VoD8=";
  };

  dontWrapQtApps = true;

  buildInputs = with pkgs.libsForQt5.qt5; [qtgraphicaleffects];

  installPhase = let
    iniFormat = pkgs.formats.ini {};
    configFile = iniFormat.generate "" {General = themeConfig;};

    basePath = "$out/share/sddm/themes/eucalyptus-drop";
  in
    ''
      mkdir -p ${basePath}
      cp -r $src/* ${basePath}
    ''
    + lib.optionalString (themeConfig != null) ''
      ln -sf ${configFile} ${basePath}/theme.conf.user
    '';
}
