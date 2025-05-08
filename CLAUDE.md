# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains NixOS and nix-darwin configurations using a flake-based approach. It configures both Linux (NixOS) and macOS (nix-darwin) systems using a modular structure.

### Key Components

- **flake.nix**: Core file defining inputs (dependencies) and outputs (system configurations)
- **hosts/**: Host-specific configurations
  - **R2D2/**: macOS configuration
  - **piplup/**: NixOS configuration
- **modules/**: Shared configuration modules
  - **darwin/**: macOS-specific modules
  - **nixos/**: NixOS-specific modules
  - **home-manager/**: User environment configuration (works on both systems)

## Common Commands

### System Management

For macOS (R2D2):
```bash
# Build and switch to the new configuration
darwin-rebuild switch --flake .#R2D2

# Build without switching (to test)
darwin-rebuild build --flake .#R2D2
```

For NixOS (piplup):
```bash
# Build and switch to the new configuration
nixos-rebuild switch --flake .#piplup

# Build without switching (to test)
nixos-rebuild build --flake .#piplup
```

Using the `nh` tool (available in both systems):
```bash
# Apply changes
nh os switch
```

### Development

```bash
# Format all Nix files
nix fmt

# Update flake lock file
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

## Project Structure

- **flake.nix**: Defines system configurations, inputs, and outputs
- **hosts/**: Contains per-host configurations
  - Each host directory contains:
    - **default.nix**: Entry point for the host configuration
    - **configuration.nix**: System-specific configuration
    - **secrets.nix**: Encrypted secrets (using agenix)
- **modules/**: Reusable configuration modules
  - **darwin/**: macOS-specific modules (homebrew, etc.)
  - **nixos/**: NixOS-specific modules (core, graphical)
  - **home-manager/**: User environment shared between both systems
    - **cli.nix**: CLI tools and utilities
    - **shell.nix**: Shell configuration (fish)
    - **editors/neovim.nix**: Neovim configuration
    - **graphical/**: GUI applications and configurations
    - **custom/**: Custom package definitions

## Best Practices

1. When making changes, test using `build` before applying with `switch`
2. Follow the existing modular architecture
3. For macOS, use homebrew modules for managing casks and formulae
4. Custom packages should be placed in `modules/home-manager/custom/`
5. Host-specific configurations go in the respective host directory
6. Shared modules go in the appropriate directory under `modules/`