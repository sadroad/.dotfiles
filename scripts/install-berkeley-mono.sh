#!/usr/bin/env bash

set -e

if [ "$#" -ne 8 ]; then
    echo "Error: Expected 8 command path arguments, but received $#." >&2
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

run_cmd() {
    local cmd_path="$1"
    shift
    if [ ! -x "$cmd_path" ]; then
        echo "Error: Command path '$cmd_path' is not executable." >&2
        [ "$DRY_RUN" != "1" ] && exit 1
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

echo "Installing Berkeley Mono font for user $USER..."

decrypted_zip="/run/agenix/berkeley_mono.zip"
font_dir="$HOME/.local/share/fonts/opentype/berkeley-mono"

if [ ! -r "$decrypted_zip" ]; then
  echo "Error: File $decrypted_zip not found or not readable. Skipping font installation."
  exit 0
fi
echo "Found readable font archive: $decrypted_zip"

run_cmd "$mkdir_cmd" -p "$font_dir" || { echo "Error: Failed to create directory $font_dir" >&2; exit 1; }
echo "Font directory created: $font_dir"

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

echo "Unzipping to temporary directory: $temp_unzip_dir"
run_cmd "$unzip_cmd" -o "$decrypted_zip" -d "$temp_unzip_dir" || { echo "Error: Failed to unzip $decrypted_zip" >&2; exit 1; }

expected_otf_source_dir="$temp_unzip_dir/250417YP79Q86941/TX-02-P6NK0YN7"

echo "Copying .otf files from $expected_otf_source_dir..."

if [ "$DRY_RUN" != "1" ] && [ ! -d "$expected_otf_source_dir" ]; then
    echo "Error: Expected source directory '$expected_otf_source_dir' does not exist." >&2
    ls -lRa "$temp_unzip_dir"
    exit 1
fi

if [ "$DRY_RUN" != "1" ]; then
    shopt -s nullglob
    otf_files=("$expected_otf_source_dir"/*.otf)
    shopt -u nullglob

    if [ ''${#otf_files[@]} -eq 0 ]; then
        echo "Error: No .otf files found in '$expected_otf_source_dir'." >&2
        exit 1
    fi
    run_cmd "$cp_cmd" "$expected_otf_source_dir"/*.otf "$font_dir/" || { echo "Error: Failed to copy .otf files" >&2; exit 1; }
    echo "Copied ${#otf_files[@]} .otf file(s)."
else
    echo "[DRY RUN] $cp_cmd $expected_otf_source_dir/*.otf $font_dir/"
fi
# --- End direct copy ---

run_cmd "$chmod_cmd" -R u+rwX "$font_dir" || { echo "Error: Failed to chmod $font_dir" >&2; exit 1; }

echo "Font files installed in $font_dir"

if [ -n "$fc_cache_cmd" ] && [ -x "$fc_cache_cmd" ]; then
    echo "Updating font cache..."
    run_cmd "$fc_cache_cmd" -fv || echo "fc-cache command failed (non-critical)."
else
    echo "fc-cache command not found, skipping cache update."
fi

echo "Berkeley Mono font installation finished."

exit 0

