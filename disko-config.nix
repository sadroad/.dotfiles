{
  disko.devices = {
    disk = {
      nvme_ssd = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_2TB_S7HGNJ0Y304436B";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              type = "EF00"
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              name = "NixOS_Root";
              size = "250G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            home = {
              name = "NixOS_Home";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };
          };
        };
      };
      sata_ssd_windows_os = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S2RANX0J120529X";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            MSR_sdb = {
              name = "MSR_WinOS";
              type = "0C01";
              size = "128M";
            };
            Windows_C = {
              name = "Windows_C";
              type = "0700";
              size = "100%";
            };
          };
        };
      };

      sata_ssd_windows_games = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_2TB_S6R4NJ0R610986Z";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            MSR_sda = {
              name = "MSR_WinGames";
              type = "0C01";
              size = "128M";
            };
            Windows_Games = {
              name = "Windows_Games";
              type = "0700";
              size = "100%";
            };
          };
        };
      };

      sata_ssd_nixos_extra = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S12RNEACA05660D";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            swap = {
              name = "NixOS_Swap";
              size = "64G";
              content = {
                type = "swap";
                priority = 1;
              };
            };
            other_os_space = {
              name = "OtherOS_Space";
              size = "100%";
            };
          };
        };
      };

      hdd_shared = {
        device = "/dev/disk/by-id/ata-ST2000DM008-2UB102_ZFL8MA3T";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            shared = {
              name = "SharedData";
              size = "100%";
              type = "0700";
              content = {
                type = "filesystem";
                format = "ntfs";
                mountpoint = "/data";
                # mountOptions = [ "rw" "uid=1000" "gid=100" "umask=007" ];
              };
            };
          };
        };
      };
    };
  };
}
