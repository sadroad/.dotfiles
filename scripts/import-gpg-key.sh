#!/usr/bin/env sh

set -e

DECRYPTED_KEY_PATH="$1"

if [ -z "$DECRYPTED_KEY_PATH" ]; then
  echo "Error: No key path provided." >&2
  exit 1
fi

if [ ! -f "$DECRYPTED_KEY_PATH" ]; then
  echo "Error: Key file not found at '$DECRYPTED_KEY_PATH'" >&2
  exit 1
fi

echo "Processing GPG key from $DECRYPTED_KEY_PATH"
FINGERPRINT=$(gpg --show-keys --with-colons --fingerprint < "$DECRYPTED_KEY_PATH" 2>/dev/null | grep "^fpr:" | head -n 1 | cut -d: -f10)

if [ -z "$FINGERPRINT" ]; then
  echo "Error: Could not extract fingerprint from $DECRYPTED_KEY_PATH" >&2
  exit 1
fi
echo "Extracted fingerprint: $FINGERPRINT"

# Ensure we have a clean fingerprint with no whitespace
FINGERPRINT=$(echo "$FINGERPRINT" | tr -d '[:space:]')

# --- Import Key ---
echo "Importing key..."
gpg --batch --import "$DECRYPTED_KEY_PATH"

echo "Setting trust for $FINGERPRINT to ultimate..."
TRUST_FILE=$(mktemp)
echo "$FINGERPRINT:6:" > "$TRUST_FILE"
gpg --import-ownertrust "$TRUST_FILE"
rm -f "$TRUST_FILE"

echo "GPG key import and trust setting complete."

