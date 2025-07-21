{
  config,
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

  backgroundImage = ../../assets/change.jpg;

  dontWrapQtApps = true;
  nativeBuildInputs = [pkgs.makeWrapper];
  buildInputs = with pkgs.libsForQt5.qt5; [qtgraphicaleffects];

  installPhase = let
    base = "$out/share/sddm/themes/eucalyptus-drop";
  in ''
    mkdir -p ${base}
    cp -r $src/* ${base}

    # Copy the background image to the theme directory
    cp ${backgroundImage} ${base}/change.jpg

    substituteInPlace ${base}/theme.conf \
      --replace 'Background="Background.jpg"' 'Background="change.jpg"'
    
    # Make the login panel more transparent
    substituteInPlace ${base}/Main.qml \
      --replace 'opacity: config.PartialBlur == "true" ? 0.3 : 1' \
                'opacity: config.PartialBlur == "true" ? 0.4 : 0.5'
  '';
}
