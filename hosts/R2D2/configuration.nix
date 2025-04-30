{
  pkgs,
  lib,
  username,
  ...
}: {
  users = {
    knownUsers = [username];
    users.${username}.uid = 501;
    users.${username}.shell = pkgs.fish;
  };
}
