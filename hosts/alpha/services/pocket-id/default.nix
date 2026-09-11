{
  config,
  lib,
  secrets,
  ...
}:

let
  encryptionKey = config.sops.secrets.pocket-id-encryption-key;
  secretUnits = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
in
{
  sops.secrets.pocket-id-encryption-key = {
    sopsFile = secrets.alphaPocketId;
    uid = 1000;
    gid = 1000;
    mode = "0400";
    restartUnits = [ "pocket-id.service" ];
  };

  preservation = {
    enable = true;

    preserveAt."/persist".directories = [
      {
        directory = "/var/lib/pocket-id";
        user = "1000";
        group = "1000";
        mode = "0750";
      }
    ];
  };

  virtualisation.quadlet = {
    enable = true;

    # Shared by Caddy and Pocket ID.
    networks.auth = {
      networkConfig.interfaceName = "podman-auth";
    };

    containers.pocket-id = {
      unitConfig = {
        RequiresMountsFor = [ "/var/lib/pocket-id" ];
        After = secretUnits;
        Requires = secretUnits;
      };

      containerConfig = {
        image = "ghcr.io/11notes/pocket-id:2.14.0";

        networks = [ config.virtualisation.quadlet.networks.auth.ref ];

        networkAliases = [ "pocket-id" ];

        environments = {
          APP_URL = "https://id.example.com";

          # Only connect trusted services to the auth network.
          TRUST_PROXY = "true";

          # Explicitly keep SQLite inside the persistent bind mount.
          DB_CONNECTION_STRING = "/pocket-id/var/pocket-id.db";

          ENCRYPTION_KEY_FILE = "/run/secrets/pocket-id-encryption-key";
        };

        volumes = [
          "/var/lib/pocket-id:/pocket-id/var"
          "${encryptionKey.path}:/run/secrets/pocket-id-encryption-key:ro"
        ];

        readOnly = true;
        noNewPrivileges = true;
        dropCapabilities = [ "ALL" ];

        # Retain the image's built-in health command.
        healthInterval = "60s";
        healthTimeout = "5s";
        healthStartPeriod = "30s";

        # Let systemd restart the container after a failed health check.
        healthOnFailure = "kill";
      };

      serviceConfig = {
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };

  networking.firewall.interfaces."podman-auth" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
