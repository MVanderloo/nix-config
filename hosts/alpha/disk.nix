{ lib, ... }:

{
  disko.devices.nodev."/" = {
    fsType = "tmpfs";
    mountOptions = [
      "defaults"
      "size=64M"
      "mode=0755"
    ];
  };

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";

    content = {
      type = "gpt";

      partitions = {
        bios = {
          priority = 100;
          size = "1M";
          # Disko's installation test recognizes EF02 as BIOS GRUB.
          type = "EF02";
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

        nix = {
          size = "100%";

          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            extraArgs = [
              "-L"
              "nix"
            ];
            mountOptions = [ "noatime" ];
          };
        };
      };
    };
  };

  disko.tests = {
    extraConfig = { pkgs, ... }: {
      # Exercise the real storage configuration without production credentials
      # or DigitalOcean's metadata endpoint in the isolated test VM.
      system.activationScripts.setupSecrets.text = lib.mkForce "";
      system.activationScripts.setupSecretsForUsers.text = lib.mkForce "";
      systemd.services.sops-install-secrets.enable = false;
      systemd.services.sops-install-secrets-for-users.enable = false;
      users.users.mv.hashedPasswordFile = lib.mkForce null;
      users.users.mv.hashedPassword = lib.mkForce "!";
      home-manager.users = lib.mkForce { };
      virtualisation.quadlet.containers = lib.mkForce { };
      services.cloud-init.enable = lib.mkForce false;
      services.tailscale.enable = lib.mkForce false;
      services.do-agent.enable = lib.mkForce false;
      systemd.services.digitalocean-metadata.enable = false;
      systemd.services.digitalocean-entropy-seed.enable = false;
      systemd.services.systemd-networkd-wait-online.enable = false;

      # The real migration restores the SSH identity before the first boot.
      # Seed a disposable key on the test disk before Preservation binds it.
      boot.initrd.systemd.services.seed-test-identity = {
        requiredBy = [ "initrd-switch-root.target" ];
        before = [ "initrd-switch-root.target" ];
        requires = [ "sysroot-nix.mount" ];
        after = [ "sysroot-nix.mount" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        path = [
          pkgs.coreutils
          pkgs.openssh
        ];
        script = ''
          key=/sysroot/nix/persist/etc/ssh/ssh_host_ed25519_key
          if [ ! -s "$key" ]; then
            mkdir -p /sysroot/nix/persist/etc/ssh
            # Preservation has already created an empty placeholder. Generate
            # elsewhere so ssh-keygen does not prompt to overwrite that file.
            ssh-keygen -q -t ed25519 -N "" -f /run/alpha-test-host-key
            cp /run/alpha-test-host-key "$key"
            cp /run/alpha-test-host-key.pub "$key.pub"
          fi
        '';
      };
    };

    extraChecks = ''
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("preservation.target")
      machine.wait_for_open_port(22)
      machine.succeed("test $(findmnt -n -o FSTYPE /) = tmpfs")
      machine.succeed("test $(findmnt -b -n -o SIZE /) = 67108864")
      machine.succeed("test $(findmnt -n -o FSTYPE /nix) = ext4")
      machine.succeed("test $(findmnt -n -o FSTYPE /home) = ext4")
      machine.succeed("test $(findmnt -n -o FSTYPE /tmp) = ext4")
      machine.succeed("test $(findmnt -n -o FSTYPE /var/tmp) = ext4")
      machine.succeed("test $(stat -c %a /tmp) = 1777")
      machine.succeed("test $(stat -c %a /var/tmp) = 1777")
      machine.succeed("swapon --show=NAME --noheadings | grep -Fx /nix/persist/swapfile")
      machine.succeed("test -s /nix/persist/etc/ssh/ssh_host_ed25519_key")
      machine.succeed("cp /etc/machine-id /nix/persist/test-machine-id")
      machine.succeed("cp /etc/ssh/ssh_host_ed25519_key.pub /nix/persist/test-host-key.pub")
      machine.succeed("touch /root-must-disappear /tmp/must-disappear /var/tmp/must-disappear")
      machine.succeed("touch /home/must-survive /var/lib/caddy/must-survive /var/lib/pocket-id/must-survive")
      machine.succeed("test -f /nix/persist/home/must-survive")
      machine.succeed("test -f /nix/persist/tmp/must-disappear")
      # Disko starts the installed VM with QEMU's -no-reboot. Power it off and
      # start it again to test a second boot from the same persistent disk.
      machine.shutdown()
      machine.start()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("preservation.target")
      machine.wait_for_open_port(22)
      machine.succeed("test $(findmnt -n -o FSTYPE /) = tmpfs")
      machine.succeed("test $(findmnt -n -o FSTYPE /nix) = ext4")
      machine.fail("test -e /root-must-disappear")
      machine.fail("test -e /tmp/must-disappear")
      machine.fail("test -e /var/tmp/must-disappear")
      machine.succeed("test -f /home/must-survive")
      machine.succeed("test -f /var/lib/caddy/must-survive")
      machine.succeed("test -f /var/lib/pocket-id/must-survive")
      machine.succeed("cmp /etc/machine-id /nix/persist/test-machine-id")
      machine.succeed("cmp /etc/ssh/ssh_host_ed25519_key.pub /nix/persist/test-host-key.pub")
    '';
  };
}
