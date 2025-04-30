{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./graphical/linux.nix

    # (lib.mkIf pkgs.stdenv.isDarwin ./graphical/darwin.nix)
  ];
}
