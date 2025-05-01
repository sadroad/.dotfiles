{
  pkgs,
  lib,
  username,
  userDir,
  ...
}: {
  users = {
    knownUsers = [username];
    users.${username} = {
      uid = 501;
      shell = pkgs.fish;
      home = userDir;
    };
  };
}
