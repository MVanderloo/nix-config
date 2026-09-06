{ config, ... }:

let
  stateDirectory = "/var/lib/caddy";
in
{
  assertions = [
    {
      assertion = config.services.tailscale.enable;
      message = "The transitional Caddy configuration requires Tailscale to reach FreshRSS on omega";
    }
  ];

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 443 ];
  };

  virtualisation.oci-containers.containers.caddy = {
    image = "docker.io/library/caddy:2.11.4-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648";

    capabilities = {
      ALL = false;
      NET_BIND_SERVICE = true;
    };

    extraOptions = [
      "--health-cmd=curl --fail --silent --show-error http://127.0.0.1:2019/config/"
      "--health-interval=30s"
      "--health-on-failure=kill"
      "--health-retries=3"
      "--health-start-period=5s"
      "--health-timeout=5s"
      "--memory=256m"
      "--memory-swap=256m"
      "--pids-limit=128"
      "--read-only"
      "--security-opt=no-new-privileges"
      "--tmpfs=/tmp:rw,nosuid,nodev,noexec,size=16m"
    ];

    podman.sdnotify = "healthy";

    ports = [
      "80:80/tcp"
      "443:443/tcp"
      "443:443/udp"
    ];

    pull = "missing";

    volumes = [
      "${./Caddyfile}:/etc/caddy/Caddyfile:ro"
      "${stateDirectory}/config:/config"
      "${stateDirectory}/data:/data"
    ];
  };

  systemd = {
    services.podman-caddy = {
      requires = [ "tailscaled.service" ];
      after = [ "tailscaled.service" ];
    };

    tmpfiles.rules = [
      "d ${stateDirectory} 0700 root root -"
      "d ${stateDirectory}/config 0700 root root -"
      "d ${stateDirectory}/data 0700 root root -"
    ];
  };

  preservation.preserveAt."/persist".directories = [
    {
      directory = stateDirectory;
      mode = "0700";
    }
  ];
}
