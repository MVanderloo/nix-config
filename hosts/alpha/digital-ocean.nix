{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  # Let cloud-init render DigitalOcean's network configuration through networkd.
  networking.useDHCP = false;

  # digital-ocean-config.nix already enables boot.growPartition.
  fileSystems."/".autoResize = true;

  virtualisation.digitalOcean = {
    rebuildFromUserData = false;
    setSshKeys = false;
  };

  services.cloud-init = {
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
}
