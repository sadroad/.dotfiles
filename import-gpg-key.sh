#!/bin/sh
# Script to import a GPG key and set its trust to ultimate.
# Expects the path to the decrypted GPG key file as the first argument.

set -e # Exit immediately if a command exits with a non-zero status.

DECRYPTED_KEY_PATH="$1"

# --- Input Validation ---
if [ -z "$DECRYPTED_KEY_PATH" ]; then
  echo "Error: No key path provided to script." >&2
  exit 1
fi

if [ ! -f "$DECRYPTED_KEY_PATH" ]; then
  echo "Error: Key file not found at '$DECRYPTED_KEY_PATH'" >&2
  # Don't exit here, ConditionPathExists in systemd unit should prevent this state
  # exit 1 
fi

echo "Attempting to process GPG key from $DECRYPTED_KEY_PATH"

# --- Extract Fingerprint ---
# Uses gpg, grep, cut which must be in PATH
FINGERPRINT=$(gpg --show-keys --with-colons --fingerprint < "$DECRYPTED_KEY_PATH" 2>/dev/null | grep "^fpr:" | cut -d: -f10)

if [ -z "$FINGERPRINT" ]; then
  echo "Error: Could not extract fingerprint from $DECRYPTED_KEY_PATH" >&2
  exit 1
fi
echo "Extracted fingerprint: $FINGERPRINT"

# --- Import Key ---
echo "Importing key..."
gpg --batch --import "$DECRYPTED_KEY_PATH"

# --- Set Trust ---
echo "Setting trust for $FINGERPRINT to ultimate..."
echo "$FINGERPRINT:6:" | gpg --import-ownertrust -

echo "GPG key import and trust setting complete."

exit 0

