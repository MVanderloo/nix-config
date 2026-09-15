{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  # Let cloud-init render DigitalOcean's network configuration through networkd.
  networking.useDHCP = false;

  # DigitalOcean's grow service assumes / is a disk-backed filesystem.
  boot.growPartition = lib.mkForce false;
  fileSystems."/".autoResize = false;

  # Both DigitalOcean and Disko nominate this BIOS disk. Keep one entry while
  # allowing Disko's test override (priority 70) to select the install disk.
  boot.loader.grub.devices = lib.mkOverride 90 [ config.disko.devices.disk.main.device ];

  virtualisation.digitalOcean = {
    rebuildFromUserData = false;
    setSshKeys = false;
  };

  services = {
    # save memory
    do-agent.enable = false;

    cloud-init = {
      enable = true;
      network.enable = true;

      settings = {
        datasource_list = [
          "ConfigDrive"
          "DigitalOcean"
        ];

        updates.network.when = [ "boot" ];

        preserve_hostname = true;

        cloud_init_modules = [ ];
        cloud_config_modules = [ ];
        cloud_final_modules = [ ];
      };
    };
  };
}
