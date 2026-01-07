{
  config,
  pkgs,
  lib,
  ...
}:
{
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  powerManagement.cpuFreqGovernor = "performance";

  boot.kernelParams = [
    "intel_pstate=active"
    "transparent_hugepage=madvise"
    "preempt=full"
    "threadirqs"
    "intel_iommu=on"
    "iommu=pt"
  ];

  services.thermald.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = -2;
    algorithm = "zstd";
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_expire_centisecs" = 3000;
    "vm.dirty_writeback_centisecs" = 500;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "vm.overcommit_memory" = 1;
    "vm.overcommit_ratio" = 50;
    "vm.min_free_kbytes" = 65536;
  };

  nix.settings = {
    max-jobs = 8;
    cores = 3;
    max-substitution-jobs = 64;
    min-free = 512 * 1024 * 1024;
    max-free = 5000 * 1024 * 1024;
    auto-optimise-store = true;
    http-connections = 50;
    builders-use-substitutes = true;
  };

  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
  nix.daemonIOSchedPriority = 7;

  nix.nrBuildUsers = 16;

  services.fstrim.enable = true;

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
  '';

  boot.loader.timeout = 5;

  systemd.settings.Manager = {
    DefaultTimeoutStartSec = 10;
    DefaultTimeoutStopSec = 10;
  };

  services.journald.extraConfig = ''
    SystemMaxUse = 2G
    RuntimeMaxUse = 256M
    SystemMaxFileSize = 128M
    SystemMaxFiles = 100
  '';
  services.journald.rateLimitBurst = 1000;
  services.journald.rateLimitInterval = "1s";

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/enabled - - - - always"
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer"
    "w /sys/kernel/mm/transparent_hugepage/shmem_enabled - - - - within_size"
  ];
}
