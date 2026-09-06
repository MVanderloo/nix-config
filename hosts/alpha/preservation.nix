{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  rootDevice = config.fileSystems."/".device;
  rootDeviceUnit = "${utils.escapeSystemdPath rootDevice}.device";
in
{
  preservation = {
    enable = true;

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
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];

      directories = [
        "/etc/nixos"
        "/srv"
        "/var/lib/cloud"
        {
          directory = "/var/lib/containers";
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
        "/var/lib/systemd/timers"
        "/var/log"
      ];
    };
  };

  boot.initrd.systemd = {
    enable = true;

    services.reset-root = {
      description = "Reset the Btrfs root subvolume";
      wantedBy = [ "initrd.target" ];
      requires = [ rootDeviceUnit ];
      requiredBy = [ "sysroot.mount" ];
      after = [ rootDeviceUnit ];
      before = [ "sysroot.mount" ];
      path = [
        pkgs.btrfs-progs
        pkgs.coreutils
        pkgs.util-linux
      ];

      unitConfig.DefaultDependencies = false;
      serviceConfig.Type = "oneshot";

      script = ''
        set -euo pipefail

        btrfsRoot=/run/btrfs-root
        mkdir -p "$btrfsRoot"
        mount -t btrfs -o subvolid=5 ${lib.escapeShellArg rootDevice} "$btrfsRoot"
        trap 'umount "$btrfsRoot"' EXIT

        if ! btrfs subvolume show "$btrfsRoot/root-blank" >/dev/null; then
          echo "Missing Btrfs root-blank subvolume" >&2
          exit 1
        fi

        if btrfs subvolume show "$btrfsRoot/root" >/dev/null 2>&1; then
          btrfs subvolume list -o "$btrfsRoot/root" \
            | cut -d' ' -f9- \
            | sort -r \
            | while read -r subvolume; do
                btrfs subvolume delete "$btrfsRoot/$subvolume"
              done

          btrfs subvolume delete "$btrfsRoot/root"
        fi

        btrfs subvolume snapshot "$btrfsRoot/root-blank" "$btrfsRoot/root"
      '';
    };
  };

  fileSystems."/persist".neededForBoot = true;

  services.journald.settings.Journal = {
    Storage = "persistent";
    SystemMaxUse = "1G";
    MaxRetentionSec = "14day";
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
