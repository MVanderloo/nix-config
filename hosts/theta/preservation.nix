{ config, lib, ... }:

let
  enablePreservation = false;
in
{
  # Enabling Preservation on an existing system does not migrate data. First
  # create the /persist Btrfs subvolume and seed the paths declared below.
  preservation = {
    enable = enablePreservation;

    preserveAt."/persist" = {
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          mode = "0600";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key.pub";
          mode = "0644";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          mode = "0600";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key.pub";
          mode = "0644";
          configureParent = true;
        }
      ];

      directories = [
        {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        }
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/var/lib/tailscale";
          mode = "0700";
        }
        {
          directory = "/var/lib/containers/storage/volumes";
          mode = "0700";
          configureParent = true;
          parent.mode = "0700";
        }
        {
          directory = "/var/lib/atuin";
          user = config.users.users.mv.name;
          group = config.users.users.mv.group;
          mode = "0700";
        }
      ];
    };
  };

}
// lib.optionalAttrs enablePreservation {
  boot.initrd.systemd.enable = true;
  fileSystems."/persist".neededForBoot = true;

  # /etc/machine-id is already populated from /persist in the initrd.
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
