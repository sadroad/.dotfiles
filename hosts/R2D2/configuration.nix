{
  pkgs,
  lib,
  username,
  userDir,
  ...
}: {
  system.primaryUser = "sadroad";
  users = {
    knownUsers = [username];
    users.${username} = {
      uid = 501;
      shell = pkgs.fish;
      home = userDir;
    };
  };
}
