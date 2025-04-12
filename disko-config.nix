{
  disko.devices = {
    disk = {
      bootAndRoot = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S2RANX0J120529X";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              name = "NixOS_Root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      homeAndWin = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_2TB_S6R4NJ0R610986Z";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            MSR_sda = {
              name = "MSR_sda";
              type = "0C01";
              size = "128M";
            };
            Windows_sda = {
              name = "Windows_sda";
              type = "0700";
              size = "1T";
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

      winOnly = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S12RNEACA05660D";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            MSR_sdb = {
              name = "MSR_sdb";
              type = "0C01";
              size = "128M";
            };
            Windows_sdb = {
              name = "Windows_sdb";
              type = "0700";
              size = "100%";
            };
          };
        };
      };

      data = {
        device = "/dev/disk/by-id/ata-WDC_WD10EZEX-00BN5A0_WD-WCC3F4PZ62EV";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              name = "NisOS_Data";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/data";
              };
            };
          };
        };
      };
    };
  };
}
