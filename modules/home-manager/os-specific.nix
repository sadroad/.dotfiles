{
  pkgs,
  lib,
  ...
}: {
  imports = [
    (lib.mkIf pkgs.stdenv.isLinux ./graphical/linux.nix)

    # (lib.mkIf pkgs.stdenv.isDarwin ./graphical/darwin.nix)
  ];
}
