# Noctalia Full Migration TODO

Goal: migrate all desktop-shell features that can be handled by Noctalia, then remove overlapping local stack pieces.

## Phase 1 - Add Noctalia to flake and boot it

- [ ] Add flake inputs in `flake.nix`:
  - [ ] `noctalia` input
  - [ ] `noctalia-qs` input
  - [ ] follow `nixpkgs` for both inputs
- [ ] Wire Noctalia HM module into Linux desktop path:
  - [ ] import `inputs.noctalia.homeModules.default` for the Linux user profile
  - [ ] enable `programs.noctalia-shell.enable = true`
- [ ] Choose one startup method and keep only that one:
  - [ ] compositor startup in Niri, or
  - [ ] Noctalia HM systemd service
- [ ] First boot validation:
  - [ ] `noctalia-shell` starts
  - [ ] no duplicate instance/gap issue
  - [ ] IPC calls work from terminal

## Phase 2 - Move interaction layer to Noctalia

- [ ] Replace Niri binds with Noctalia IPC binds in `modules/home-manager/desktop/niri/binds.nix`:
  - [ ] launcher toggle
  - [ ] control center toggle
  - [ ] settings toggle
  - [ ] volume controls (raise/lower/mute)
  - [ ] brightness controls
  - [ ] session menu + lock actions
- [ ] Keep any non-overlapping custom binds (workspace nav, window movement, KVM helper)

## Phase 3 - Remove overlapping components (high-confidence)

- [ ] Remove Waybar module import from `modules/home-manager/desktop/linux.nix`
- [ ] Remove Waybar config files:
  - [ ] `modules/home-manager/desktop/waybar/default.nix`
  - [ ] `modules/home-manager/desktop/waybar/style.css`
- [ ] Remove Dunst service from `modules/home-manager/desktop/apps/default.nix`
- [ ] Remove Fuzzel package and bind usage:
  - [ ] delete from `modules/home-manager/desktop/niri/services.nix`
  - [ ] remove launcher bind in `modules/home-manager/desktop/niri/binds.nix`

## Phase 4 - Move visual/system utilities into Noctalia

- [ ] Wallpaper management migration:
  - [ ] remove `swww` package and startup commands from `modules/home-manager/desktop/niri/services.nix`
  - [ ] configure Noctalia wallpaper settings and monitor mapping
  - [ ] decide overview wallpaper mode for Niri (blurred/stationary/flat)
- [ ] Night light migration:
  - [ ] remove `wlsunset` package + startup command
  - [ ] configure Noctalia `nightLight` settings
- [ ] Notifications migration:
  - [ ] confirm Noctalia notification history/DND behavior matches current workflow

## Phase 5 - Migrate lock/idle stack (deep migration)

- [ ] Replace Hypr lock/idle stack with Noctalia equivalents where practical:
  - [ ] remove `services.hypridle` from `modules/home-manager/desktop/niri/services.nix`
  - [ ] remove `programs.hyprlock` from `modules/home-manager/desktop/niri/services.nix`
  - [ ] remove PAM entries in `modules/nixos/graphical.nix` only if no longer needed
- [ ] Re-implement required behavior through Noctalia + compositor/systemd integration:
  - [ ] lock on idle
  - [ ] lock before suspend
  - [ ] wake/monitor behavior

## Phase 6 - Optional Noctalia features to fully adopt

- [ ] Plugins:
  - [ ] declare plugin sources/states in Noctalia HM options
  - [ ] migrate plugin-specific settings
- [ ] Calendar events support:
  - [ ] enable `services.gnome.evolution-data-server.enable`
  - [ ] switch package to `calendarSupport = true` override if desired
- [ ] Theme pipeline:
  - [ ] define Noctalia color scheme in Nix
  - [ ] optionally enable template generation for app theming
- [ ] Wallpapers file management:
  - [ ] manage `~/.cache/noctalia/wallpapers.json` declaratively if needed

## Phase 7 - Cleanup and hardening

- [ ] Remove no-longer-used packages from desktop package lists
- [ ] Remove dead module files/imports and ensure no orphan references remain
- [ ] Run formatting and checks:
  - [ ] `nix fmt`
  - [ ] `nix flake check`
- [ ] Host-level dry-run checks:
  - [ ] `nix build --dry-run .#nixosConfigurations.piplup.config.system.build.toplevel`
- [ ] Runtime verification checklist:
  - [ ] bar/control center/launcher/notifications work
  - [ ] audio + brightness keys work
  - [ ] lock/session actions work
  - [ ] wallpaper + night light work
  - [ ] no duplicate shell instances

## Final target state

- [ ] Noctalia is the only shell layer for bar, notifications, launcher, wallpaper, and system controls.
- [ ] Legacy overlap (Waybar, Dunst, Fuzzel, Swww, Wlsunset, optional Hyprlock/Hypridle) is fully removed.
- [ ] Configuration remains declarative and reproducible via Nix.
