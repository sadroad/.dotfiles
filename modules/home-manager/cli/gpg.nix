{
  osConfig,
  pkgs,
  lib,
  secretsAvailable,
  ...
}:
lib.mkIf secretsAvailable (let
  decryptedKeyPath = osConfig.age.secrets."sadroad-gpg-private".path;

  importScript = ../../../scripts/import-gpg-key.sh;
in {
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package =
      if pkgs.stdenv.isDarwin
      then pkgs.pinentry_mac
      else pkgs.pinentry-tty;
    defaultCacheTtl = 4 * 60 * 60;
  };

  home.activation.importGpgKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${lib.makeBinPath [pkgs.gnupg pkgs.gnugrep pkgs.coreutils]}:$PATH"

    if [ ! -f "${decryptedKeyPath}" ]; then
      echo "GPG Import Activation: Decrypted key file ${decryptedKeyPath} not found. Skipping import." >&2
    else
      echo "GPG Import Activation: Attempting to import key from ${decryptedKeyPath}"
      ${importScript} "${decryptedKeyPath}" || echo "GPG Import Activation: Import script failed." >&2
    fi
  '';
})
