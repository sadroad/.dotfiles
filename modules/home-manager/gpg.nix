# modules/home-manager/gpg.nix
{
  osConfig,
  pkgs,
  lib,
  secretsAvailable,
  ...
}:
lib.mkIf secretsAvailable (let
  decryptedKeyPath = osConfig.age.secrets."sadroad-gpg-private".path;

  importScript = ../../scripts/import-gpg-key.sh;
in {
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
    defaultCacheTtl = 4 * 60 * 60; # 4 hours
  };

  home.activation.importGpgKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Ensure necessary commands are in PATH
    export PATH="${lib.makeBinPath [pkgs.gnupg pkgs.gnugrep pkgs.coreutils]}:$PATH"

    # Check if the decrypted key file exists
    if [ ! -f "${decryptedKeyPath}" ]; then
      echo "GPG Import Activation: Decrypted key file ${decryptedKeyPath} not found. Skipping import." >&2
    else
      echo "GPG Import Activation: Attempting to import key from ${decryptedKeyPath}"
      # Run the import script
      ${importScript} "${decryptedKeyPath}" || echo "GPG Import Activation: Import script failed." >&2
    fi
  '';
})
