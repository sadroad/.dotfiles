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
# Only take the first fingerprint in case there are multiple keys
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

# --- Set Trust ---
echo "Setting trust for $FINGERPRINT to ultimate..."
# The format for trust is FINGERPRINT:TRUST_VALUE: (must end with colon)
# Create a temporary file for the ownertrust to avoid issues with pipes
TRUST_FILE=$(mktemp)
echo "$FINGERPRINT:6:" > "$TRUST_FILE"
gpg --import-ownertrust "$TRUST_FILE"
rm -f "$TRUST_FILE"

echo "GPG key import and trust setting complete."

exit 0

