{
  pkgs,
  lib,
  secretsAvailable,
  ...
}: {
  home = {
    activation.installBerkeleyMonoFont = lib.mkIf secretsAvailable (let
      installScript = ../../../scripts/install-berkeley-mono.sh;
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${installScript} \
          "${pkgs.unzip}/bin/unzip" \
          "${pkgs.coreutils}/bin/mkdir" \
          "${pkgs.coreutils}/bin/cp" \
          "${pkgs.coreutils}/bin/rm" \
          "${pkgs.coreutils}/bin/chmod" \
          "${pkgs.coreutils}/bin/mktemp" \
          "${pkgs.fontconfig.bin}/bin/fc-cache" \
      '');
    pointerCursor = {
      enable = true;
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      hyprcursor.enable = true;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
    sessionVariables = {
      NIXOS_ZONE_WL = "1";
    };
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [fcitx5-hangul];
    };
  };
}
