{ config, pkgs, ... }:
{
  programs.niri.settings = {
    xwayland-satellite.path = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
    outputs."DP-2" = {
      mode = {
        width = 2560;
        height = 1440;
        refresh = 180.0;
      };
      position = {
        x = 0;
        y = 0;
      };
    };

    outputs."DP-3" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 165.0;
      };
      position = {
        x = -1920;
        y = 0;
      };
    };

    outputs."HDMI-A-1" = { };

    input = {
      keyboard.xkb.layout = "us";
      mouse.accel-profile = "flat";
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
    };

    layout = {
      gaps = 10;
      focus-ring.enable = false;
      border.enable = false;
      shadow = {
        enable = true;
      };
      default-column-width = {
        proportion = 0.5;
      };
    };

    prefer-no-csd = true;
    screenshot-path = "~/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
    hotkey-overlay.skip-at-startup = true;
    animations.enable = false;

    spawn-at-startup = [
      { command = [ "ghostty" ]; }
    ];

    window-rules = [
      {
        matches = [ { app-id = "org.pulseaudio.pavucontrol"; } ];
        open-floating = true;
      }
      {
        matches = [
          { app-id = "^(Proton Pass|proton-pass)$"; }
        ];
        block-out-from = "screencast";
      }
      {
        matches = [ { app-id = ".*"; } ];
        variable-refresh-rate = true;
      }
    ];

    layer-rules = [
      {
        matches = [ { namespace = "^notifications$"; } ];
        block-out-from = "screencast";
      }
    ];
  };

  imports = [
    ./binds.nix
    ./services.nix
  ];
}
