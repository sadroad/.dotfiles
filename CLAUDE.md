# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS and nix-darwin dotfiles configuration repository using nix flakes, home-manager, and agenix for secrets management. It manages system configurations for:
- "piplup" (x86_64-linux)
- "R2D2" (aarch64-darwin)

## Commands

### System Management
```
# Format all nix files
nix fmt

# Build system (NixOS)
sudo nixos-rebuild switch --flake .#piplup

# Build system (Darwin)
nix run nix-darwin -- switch --flake .#R2D2

# Update a flake input
nix flake update <input-name>

# Check system configuration without building
nixos-rebuild check --flake .#piplup
darwin-rebuild check --flake .#R2D2
```

### Development
```
# Update Claude Code package
cd modules/home-manager/custom/claude
./update.sh

# Install Berkeley Mono font
./scripts/install-berkley-mono.sh

# Import GPG key
./scripts/import-gpg-key.sh
```

### Shell Configuration
The repository uses fish shell with custom aliases. Notable mappings:
- `ls` → `eza`
- `cat` → `bat`
- `grep` → `rg` (ripgrep)
- `find` → `fd`
- `cd` → `z` (zoxide)

## Architecture

### Directory Structure
- `/flake.nix`: Main flake definition with inputs and system configurations
- `/hosts/`: Host-specific configurations (piplup, R2D2)
- `/modules/`: Shared configuration modules
  - `home-manager/`: User-level configurations (CLI, graphical, editors)
  - `nixos/`: NixOS system modules
  - `darwin/`: macOS-specific modules
- `/scripts/`: Utility scripts

### Key Configuration Patterns
- All packages are managed through nix
- Secrets are managed with agenix (referenced from private git repo)
- Home-manager handles user-specific configurations
- Platform-specific configurations are split between nixos and darwin modules

### Formatter
The repository uses `alejandra` as the nix formatter.