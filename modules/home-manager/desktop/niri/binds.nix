{ pkgs, ... }:
{
  programs.niri.settings.binds = let
    workspaceBinds = builtins.listToAttrs (
      builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = i + 1;
          in
          [
            {
              name = "Mod+${toString ws}";
              value.action.focus-workspace = ws;
            }
            {
              name = "Mod+Shift+${toString ws}";
              value.action.move-window-to-workspace = ws;
            }
          ]
        ) 9
      )
    );
  in
  workspaceBinds
  // {
    # Application launchers
    "Mod+R".action.spawn = "fuzzel";
    "Mod+Q".action.spawn = "ghostty";

    # Window management
    "Mod+C".action.close-window = [ ];
    "Mod+C".repeat = false;
    "Mod+M".action.quit = { skip-confirmation = true; };
    "Mod+M".repeat = false;
    "Mod+V".action.toggle-window-floating = [ ];
    "Mod+V".repeat = false;

    # Screenshot (built-in)
    "Mod+Ctrl+S".action.screenshot = [ ];
    "Mod+Ctrl+S".repeat = false;

    # Screen mirroring - focus output, press Mod+P, move wl-mirror window to target, fullscreen
    "Mod+P".action.spawn = [
      "sh"
      "-c"
      "wl-mirror $(niri msg --json focused-output | ${pkgs.jq}/bin/jq -r .name)"
    ];
    "Mod+P".repeat = false;

    # Focus navigation
    "Mod+Left".action.focus-column-left = [ ];
    "Mod+Right".action.focus-column-right = [ ];
    "Mod+Up".action.focus-window-or-workspace-up = [ ];
    "Mod+Down".action.focus-window-or-workspace-down = [ ];

    # Move columns/windows
    "Mod+Shift+Left".action.move-column-left = [ ];
    "Mod+Shift+Right".action.move-column-right = [ ];
    "Mod+Shift+Up".action.move-window-up-or-to-workspace-up = [ ];
    "Mod+Shift+Down".action.move-window-down-or-to-workspace-down = [ ];

    # Column width adjustments
    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";

    # Layout actions
    "Mod+F".action.maximize-column = [ ];
    "Mod+F".repeat = false;
    "Mod+Shift+F".action.fullscreen-window = [ ];
    "Mod+Shift+F".repeat = false;
    "Mod+Ctrl+Shift+F".action.toggle-windowed-fullscreen = [ ];
    "Mod+Ctrl+Shift+F".repeat = false;
    "Mod+T".action.toggle-column-tabbed-display = [ ];
    "Mod+T".repeat = false;

    # Mouse bindings
    "Mod+WheelScrollDown".action.focus-workspace-down = [ ];
    "Mod+WheelScrollUp".action.focus-workspace-up = [ ];

    # KVM monitor toggle (F1) - mirror HDMI-A-1 between DP-2 and DP-3
    "Mod+F1".action.spawn = [ "${./kvm-monitor-toggle.nu}" ];
    "Mod+F1".repeat = false;
  };
}
