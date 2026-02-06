_: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./style.css;
    settings = {
      mainBar = {
        height = 24;
        modules-left = [
          "niri/workspaces"
        ];
        modules-right = [
          "network"
          "pulseaudio"
          "tray"
          "clock"
        ];
        tray = {
          spacing = 10;
        };
        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:L%Y-%m-%d<small>[%a]</small> %H:%M}";
        };
        pulseaudio = {
          scroll-step = 5;
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = " {icon} {volume}% {format_source}";
          format-bluetooth-muted = "  {icon} {format_source}";
          format-muted = "  {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
          on-click-right = "ghostty -e pw-top";
        };
      };
    };
  };
}
