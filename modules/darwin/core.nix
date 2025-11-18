{
  config,
  pkgs,
  lib,
  ...
}: {
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
