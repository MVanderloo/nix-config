let
  biosGrubPartitionType = "21686148-6449-6E6F-744E-656564454649";
  mountOptions = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";

    content = {
      type = "gpt";

      partitions = {
        bios = {
          priority = 100;
          size = "1M";
          type = biosGrubPartitionType;
        };

        boot = {
          size = "1G";

          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/boot";
            extraArgs = [
              "-L"
              "boot"
            ];
            mountOptions = [ "noatime" ];
          };
        };

        root = {
          size = "100%";

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
  };
}
