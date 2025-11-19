{
  config,
  pkgs,
  lib,
  username,
  userDir,
  ...
}: {
  system.primaryUser = username;
  users = {
    knownUsers = [username];
    users.${username} = {
      uid = 501;
      home = userDir;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];
  system.defaults = {
    # Reduce window resize animation duration.
    NSGlobalDomain.NSWindowResizeTime = 0.001;

    # Reduce motion.
    CustomSystemPreferences."com.apple.Accessibility".ReduceMotionEnabled = 1;
    universalaccess.reduceMotion = true;
  };
}
