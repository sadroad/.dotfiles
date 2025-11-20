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

  launchd.daemons.limit-maxfiles = {
    script = ''
      /bin/launchctl limit maxfiles 524288 524288
    '';
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      Label = "org.nixos.limit-maxfiles";
      StandardOutPath = "/var/log/limit-maxfiles.log";
      StandardErrorPath = "/var/log/limit-maxfiles.log";
    };
  };

  environment.shellInit = ''
    ulimit -n 524288
  '';

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
