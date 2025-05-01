{
  pkgs,
  lib,
  config,
  username,
  username,
  hostname,
  ...
}: {
  imports = [
    ./graphical/linux.nix

    # (lib.mkIf pkgs.stdenv.isDarwin ./graphical/darwin.nix)
  ];

  config = {
    home.packages = with pkgs;
      lib.mkIf stdenv.isLinux [
        protonup
      ];
    home.sessionVariables = lib.mkIf pkgs.stdenv.isLinux {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
    };
  };
}
