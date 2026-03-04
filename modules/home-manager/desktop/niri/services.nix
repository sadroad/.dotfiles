{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-mirror
    nautilus # Required for xdg-desktop-portal-gnome file chooser (v47.0+)
  ];

  programs.niri.settings.spawn-at-startup = [
    {
      command = [
        "handy"
        "--start-hidden"
      ];
    }
    { command = [ "noctalia-shell" ]; }
  ];
}
