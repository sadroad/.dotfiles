{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./common.nix
  ] ++ (lib.optionals pkgs.stdenv.isLinux [
    ./linux.nix
  ]);
}
