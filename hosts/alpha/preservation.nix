{
  preservation = {
    enable = true;

    preserveAt."/nix/persist" = {
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
        "/home"
        "/srv"
        {
          directory = "/tmp";
          mode = "1777";
        }
        {
          directory = "/var/tmp";
          mode = "1777";
        }
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
        "/var/lib/systemd/coredump"
        "/var/log"
      ];
    };
  };

  boot.initrd.systemd.enable = true;
  boot.tmp.cleanOnBoot = true;
  systemd.tmpfiles.rules = [ "D! /var/tmp 1777 root root" ];

  fileSystems."/nix".neededForBoot = true;

  services.journald.settings.Journal = {
    Storage = "persistent";
    SystemMaxUse = "1G";
    MaxRetentionSec = "14day";
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
