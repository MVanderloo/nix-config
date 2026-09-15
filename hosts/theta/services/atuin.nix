{ pkgs, ... }:

let
  stateDirectory = "/var/lib/atuin";
  port = 8888;
  backendUrl = "http://127.0.0.1:${toString port}";
  image = "ghcr.io/atuinsh/atuin:18.22.0@sha256:1e94eb5c2fb6bb1e46da2591648efa11aa9507fcd80ddf812e4acbfe51d8a840";
in
{
  virtualisation.quadlet.containers.atuin = {
    autoStart = true;

    unitConfig = {
      Description = "Atuin sync server";
      After = [ "systemd-tmpfiles-setup.service" ];
      RequiresMountsFor = [ stateDirectory ];
    };

    containerConfig = {
      image = image;
      exec = [ "start" ];
      user = "1000:1000";
      readOnly = true;
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];

      environments = {
        ATUIN_DB_URI = "sqlite:///config/atuin.db";
        ATUIN_HOST = "0.0.0.0";
        ATUIN_OPEN_REGISTRATION = "false";
        ATUIN_PORT = toString port;
      };

      publishPorts = [ "127.0.0.1:${toString port}:${toString port}" ];
      volumes = [ "${stateDirectory}:/config" ];
      tmpfses = [ "/tmp:U,mode=1777" ];
      stopTimeout = 30;
    };

    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
      TimeoutStartSec = "900s";
      TimeoutStopSec = "45s";
    };
  };

  systemd = {
    tmpfiles.rules = [
      "d ${stateDirectory} 0700 1000 1000 -"
      # Adopt the database created by the previous mv-run native service.
      "Z ${stateDirectory} - 1000 1000 -"
    ];

    services.atuin-tailscale-serve = {
      description = "Expose Atuin through Tailscale Serve";
      wantedBy = [ "multi-user.target" ];
      requires = [
        "atuin.service"
        "tailscaled.service"
      ];
      after = [
        "atuin.service"
        "tailscaled.service"
      ];

      script = ''
        ${pkgs.tailscale}/bin/tailscale serve \
          --yes \
          --bg \
          --http=${toString port} \
          --set-path=/ \
          ${backendUrl}
      '';

      preStop = ''
        ${pkgs.tailscale}/bin/tailscale serve \
          --yes \
          --http=${toString port} \
          --set-path=/ \
          off
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };

  preservation.preserveAt."/persist".directories = [
    {
      directory = stateDirectory;
      user = "1000";
      group = "1000";
      mode = "0700";
    }
  ];
}
