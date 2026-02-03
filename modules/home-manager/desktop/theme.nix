{
  pkgs,
  lib,
  secretsAvailable,
  ...
}:
let
  berkeley-mono-installer = pkgs.writeShellApplication {
    name = "install-berkeley-mono";
    runtimeInputs = with pkgs; [
      unzip
      coreutils
      fontconfig
    ];
    text = ''
      set -euo pipefail

      FONT_DIR="''${HOME}/.local/share/fonts/opentype/berkeley-mono"
      SECRET_PATH="/run/agenix/berkeley_mono.zip"

      # Check if secret exists
      if [[ ! -r "$SECRET_PATH" ]]; then
        echo "Berkeley Mono secret not available at $SECRET_PATH, skipping installation"
        # Clean up existing fonts if secret was removed
        if [[ -d "$FONT_DIR" ]]; then
          echo "Removing existing Berkeley Mono fonts (secret no longer available)"
          rm -rf "$FONT_DIR"
          fc-cache -fv 2>/dev/null || true
        fi
        exit 0
      fi

      # Ensure font directory exists
      mkdir -p "$FONT_DIR"

      # Check if fonts are already up to date (compare mtimes)
      if [[ -n "$(ls -A "$FONT_DIR" 2>/dev/null)" ]] && [[ "$SECRET_PATH" -ot "$FONT_DIR" ]]; then
        echo "Berkeley Mono already installed and up to date"
        exit 0
      fi

      echo "Installing Berkeley Mono fonts..."

      # Create temp directory
      TMP=$(mktemp -d)
      trap 'rm -rf "$TMP"' EXIT

      # Extract zip
      unzip -q -o "$SECRET_PATH" -d "$TMP"

      # Find OTF files (handles any zip internal structure)
      OTF_COUNT=$(find "$TMP" -name "*.otf" -type f | wc -l)

      if [[ "$OTF_COUNT" -eq 0 ]]; then
        echo "Error: No .otf files found in the zip archive" >&2
        echo "Zip contents:" >&2
        find "$TMP" -type f >&2
        exit 1
      fi

      # Clear old fonts and install new ones
      rm -f "$FONT_DIR"/*.otf
      find "$TMP" -name "*.otf" -type f -exec cp {} "$FONT_DIR/" \;

      # Set permissions
      chmod -R u+rwX "$FONT_DIR"

      echo "Installed $OTF_COUNT OTF file(s) to $FONT_DIR"

      # Update font cache
      fc-cache -fv 2>/dev/null || echo "Font cache update failed (non-critical)"
    '';
  };
in
{
  home = {
    activation.installBerkeleyMonoFont = lib.mkIf secretsAvailable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${berkeley-mono-installer}/bin/install-berkeley-mono
      ''
    );
    pointerCursor = {
      enable = true;
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      hyprcursor.enable = true;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
    sessionVariables = {
      NIXOS_ZONE_WL = "1";
    };
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [ fcitx5-hangul ];
    };
  };
}
