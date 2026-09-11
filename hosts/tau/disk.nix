{ lib, ... }:

let
  mountOptions = [
    "compress=zstd"
    "discard=async"
    "noatime"
  ];
in
{
  disko.devices.disk.main = {
    type = "disk";
    device = lib.mkDefault "/dev/disk/by-id/nvme-eui.001b448b46b7f44a";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        root = {
          size = "100%";

          content = {
            # TODO: Encrypt disk
            type = "lvm_pv";
            vg = "tau";
          };
        };
      };
    };
  };

  disko.devices.lvm_vg.tau = {
    type = "lvm_vg";

    lvs = {
      swap = {
        size = "5%VG";
        content = {
          type = "swap";
          discardPolicy = "both";
          priority = 10;
          resumeDevice = true;
        };
      };

      system = {
        size = "100%FREE";

        content = {
          type = "btrfs";
          extraArgs = [
            "-f"
            "-L"
            "nixos"
          ];

          subvolumes = {
            "/root" = {
              mountpoint = "/";
              inherit mountOptions;
            };

            # Every boot snapshots this empty subvolume over /root.
            "/root-blank" = { };

            "/home" = {
              mountpoint = "/home";
              inherit mountOptions;
            };

            "/nix" = {
              mountpoint = "/nix";
              inherit mountOptions;
            };

            "/persist" = {
              mountpoint = "/persist";
              inherit mountOptions;
            };
          };
        };
      };
    };
  };
}
