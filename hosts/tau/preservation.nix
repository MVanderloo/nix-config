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
          how = "symlink";
          inInitrd = true;
          createLinkTarget = true;
          configureParent = true;
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
        {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        }
        {
          directory = "/var/lib/NetworkManager";
          mode = "0700";
        }
        {
          directory = "/var/lib/bluetooth";
          mode = "0700";
        }
        {
          directory = "/var/lib/iwd";
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
        "/var/lib/boltd"
        "/var/lib/cups"
        "/var/lib/fprint"
        "/var/lib/fwupd"
        "/var/lib/power-profiles-daemon"
        "/var/lib/systemd/backlight"
        "/var/lib/systemd/rfkill"
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
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

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
    SystemMaxUse = "512M";
    MaxRetentionSec = "14day";
  };

  # Commit the transient initrd machine-id to its persistent symlink target.
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persist/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persist"
    ];
  };
}
