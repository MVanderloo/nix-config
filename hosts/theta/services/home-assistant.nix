{ config, ... }:

let
  stateDirectory = "/var/lib/home-assistant";
  image = "ghcr.io/11notes/homeassistant:2026.9.2@sha256:1c0948a964b16c74453fee28a03207a0f927927c94fb1f8da3611e1bb32fa28e";
in
{
  virtualisation.quadlet.containers.home-assistant = {
    autoStart = true;

    unitConfig = {
      Description = "Home Assistant";
      After = [ "systemd-tmpfiles-setup.service" ];
      RequiresMountsFor = [ stateDirectory ];
    };

    containerConfig = {
      image = image;
      environments.TZ = config.time.timeZone;
      readOnly = true;
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];

      # Host networking lets Home Assistant discover devices on the LAN.
      networks = [ "host" ];

      volumes = [
        # Keep existing configuration and SQLite data at the same host path.
        # This also hides the image's example PostgreSQL/proxy configuration.
        "${stateDirectory}:/homeassistant/etc"
        "${stateDirectory}/.local:/homeassistant/var"
      ];
      tmpfses = [
        "/homeassistant/tmp:U,mode=0700"
      ];
      stopTimeout = 60;
    };

    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
      # The initial image pull can take longer than systemd's default timeout.
      TimeoutStartSec = "900s";
      TimeoutStopSec = "90s";
    };
  };

  networking.firewall.interfaces = {
    eno1.allowedUDPPorts = [
      1900
      5353
    ];
    wlp1s0.allowedUDPPorts = [
      1900
      5353
    ];
    tailscale0.allowedTCPPorts = [ 8123 ];
  };

  systemd.tmpfiles.rules = [
    # Match the image's default UID/GID without overriding its user.
    "d ${stateDirectory} 0700 1000 1000 -"
    "d ${stateDirectory}/.local 0700 1000 1000 -"
    # Adopt data created by the previous root-run official image.
    "Z ${stateDirectory} - 1000 1000 -"
  ];

  preservation.preserveAt."/persist".directories = [
    {
      directory = stateDirectory;
      user = "1000";
      group = "1000";
      mode = "0700";
    }
  ];
}
