#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Assign Arguments to Variables ---
# We still need the other commands
if [ "$#" -ne 8 ]; then
    echo "Activation Script Error: Expected 8 command path arguments, but received $#." >&2
    echo "Usage: $0 <unzip_path> <mkdir_path> <cp_path> <rm_path> <chmod_path> <find_path_ignored> <mktemp_path> <fc_cache_path>" >&2
    exit 1
fi

unzip_cmd="$1"
mkdir_cmd="$2"
cp_cmd="$3"
rm_cmd="$4"
chmod_cmd="$5"
# find_cmd="$6" # We won't use this argument
mktemp_cmd="$7"
fc_cache_cmd="$8"

# --- Helper function for Dry Run ---
run_cmd() {
    local cmd_path="$1"
    shift
     if [ ! -x "$cmd_path" ]; then
         echo "Activation Script Error: Command path '$cmd_path' is not executable." >&2
         [ "$DRY_RUN" != "1" ] && exit 1
         echo "(Dry run warning ignored)"
         echo "[DRY RUN - Command not executable] $cmd_path" "$@"
         return 0
     fi
    if [ "$DRY_RUN" = "1" ]; then
        echo "[DRY RUN] $cmd_path" "$@"
    else
        "$cmd_path" "$@"
    fi
    return $?
}

echo "Activation Script: Attempting to install Berkeley Mono font for user $USER..."

decrypted_zip="/run/agenix/berkeley_mono.zip"
font_dir="$HOME/.local/share/fonts/opentype/berkeley-mono" # Target directory

if [ ! -r "$decrypted_zip" ]; then
  echo "Activation Script: Decrypted file $decrypted_zip not found or not readable. Skipping font installation."
  exit 0
fi
echo "Activation Script: Found readable decrypted font archive: $decrypted_zip"

run_cmd "$mkdir_cmd" -p "$font_dir" || { echo "Activation Script: Failed to create directory $font_dir" >&2; exit 1; }
echo "Activation Script: Ensured font directory exists: $font_dir"

if [ "$DRY_RUN" = "1" ]; then
    temp_unzip_dir="/tmp/hm-dry-run-mktemp-dir"
    echo "[DRY RUN] $mktemp_cmd -d (Simulated: $temp_unzip_dir)"
else
    temp_unzip_dir=$("$mktemp_cmd" -d)
    if [ -z "$temp_unzip_dir" ]; then
        echo "Activation Script: Failed to create temporary directory" >&2; exit 1
    fi
    trap '$rm_cmd -rf "$temp_unzip_dir"' EXIT
fi

echo "Activation Script: Unzipping to temporary directory: $temp_unzip_dir"
run_cmd "$unzip_cmd" -o "$decrypted_zip" -d "$temp_unzip_dir" || { echo "Activation Script: Failed to unzip $decrypted_zip" >&2; exit 1; }

# --- Directly copy .otf files using known path ---
# Construct the expected path based on the previous log output
# NOTE: This makes the script brittle if the internal zip structure changes!
expected_otf_source_dir="$temp_unzip_dir/250417YP79Q86941/TX-02-P6NK0YN7"

echo "Activation Script: Attempting to copy .otf files from $expected_otf_source_dir..."

# Check if the source directory exists (only possible if not dry run)
if [ "$DRY_RUN" != "1" ] && [ ! -d "$expected_otf_source_dir" ]; then
    echo "Activation Script Error: Expected source directory '$expected_otf_source_dir' does not exist after unzip." >&2
    echo "Contents of $temp_unzip_dir:"
    ls -lRa "$temp_unzip_dir" # List contents for debugging
    exit 1
fi

# Use cp directly with the known path and glob
# Check if glob expands to anything before running cp (safer)
# This check only works reliably outside dry run
if [ "$DRY_RUN" != "1" ]; then
    # Check if any .otf files exist in the source directory
    shopt -s nullglob # Make glob expand to nothing if no match
    otf_files=("$expected_otf_source_dir"/*.otf)
    shopt -u nullglob # Turn off nullglob again

    if [ ''${#otf_files[@]} -eq 0 ]; then
        echo "Activation Script Error: No .otf files found in '$expected_otf_source_dir'." >&2
        exit 1
    fi
    # Now copy the files found by the glob
    run_cmd "$cp_cmd" "$expected_otf_source_dir"/*.otf "$font_dir/" || { echo "Activation Script: Failed to copy .otf files from $expected_otf_source_dir" >&2; exit 1; }
    echo "Activation Script: Copied ${#otf_files[@]} .otf file(s)."
else
    # Simulate copy in dry run
    echo "[DRY RUN] $cp_cmd $expected_otf_source_dir/*.otf $font_dir/"
fi
# --- End direct copy ---

# Permissions: Ensure readability
run_cmd "$chmod_cmd" -R u+rwX "$font_dir" || { echo "Activation Script: Failed to chmod $font_dir" >&2; exit 1; }
# We need find for the second chmod, let's skip it for now to avoid the error
# If permissions are wrong later, we can revisit.
# [ "$DRY_RUN" != "1" ] && "$find_cmd" "$font_dir" -type f -exec "$chmod_cmd" u+r {} \;
echo "Activation Script: Skipped fine-grained chmod on files to avoid find."


echo "Activation Script: Font files installed/updated in $font_dir"

# Update the user's font cache
if [ -n "$fc_cache_cmd" ] && [ -x "$fc_cache_cmd" ]; then
    echo "Activation Script: Updating user font cache using $fc_cache_cmd..."
    run_cmd "$fc_cache_cmd" -fv || echo "Activation Script: fc-cache command failed (non-critical)."
else
    echo "Activation Script: fc-cache command path ($fc_cache_cmd) not found or not executable, skipping cache update."
fi

# Cleanup is handled by the trap EXIT (if not dry run)
echo "Activation Script: Berkeley Mono font installation script finished."

exit 0

