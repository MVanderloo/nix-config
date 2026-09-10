{ config, lib, ... }:

let
  stateDirectory = "/var/lib/home-assistant";
  lanInterfaces = [
    "eno1"
    "wlp1s0"
  ];
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
      image = "ghcr.io/11notes/homeassistant:2026.9.1@sha256:8ed9d3329f31fdd1ea0ed5a05c497a3693760c99b4b5756b78fca8041d3acb6c";
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
        "/homeassistant/tmp:uid=1000,gid=1000,mode=0700"
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

  networking.firewall.interfaces =
    lib.genAttrs lanInterfaces (_: {
      # SSDP and mDNS discovery.
      allowedUDPPorts = [
        1900
        5353
      ];
    })
    // {
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
