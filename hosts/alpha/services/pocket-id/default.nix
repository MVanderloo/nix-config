{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:

let
  encryptionKey = config.sops.secrets.pocket-id-encryption-key;
  vikunjaClientSecret = config.sops.secrets.vikunja-oidc-client-secret;
  secretUnits = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
  image = "ghcr.io/11notes/pocket-id:2.14.0@sha256:3b163b8018446ddce7014bfbe5fd608b99ccaee9bf565125a51db333b8ac394f";
  apiUrl = "http://127.0.0.1:1411/api/oidc/clients";
  clientId = "vikunja";
  publicUrl = "https://todo.mvanderloo.com";
  clientConfig = {
    name = "Vikunja";
    description = "Issue tracking at ${publicUrl}";
    callbackURLs = [ "${publicUrl}/auth/openid/pocketid" ];
    logoutCallbackURLs = [ publicUrl ];
    isPublic = false;
    pkceEnabled = false;
    requiresReauthentication = false;
    requiresPushedAuthorizationRequests = false;
    skipConsent = true;
    credentials.federatedIdentities = [ ];
    launchURL = publicUrl;
    isGroupRestricted = false;
  };
  clientCreate = pkgs.writeText "pocket-id-vikunja-client-create.json" (
    builtins.toJSON (clientConfig // { id = clientId; })
  );
  clientUpdate = pkgs.writeText "pocket-id-vikunja-client-update.json" (builtins.toJSON clientConfig);
in
{
  sops = {
    secrets = {
      pocket-id-encryption-key = {
        sopsFile = secrets.alphaPocketId;
        uid = 1000;
        gid = 1000;
        mode = "0400";
        restartUnits = [ "pocket-id.service" ];
      };

      pocket-id-static-api-key = {
        sopsFile = secrets.alphaVikunja;
        mode = "0400";
        restartUnits = [
          "pocket-id.service"
          "pocket-id-vikunja-client.service"
        ];
      };

      vikunja-oidc-client-secret = {
        sopsFile = secrets.alphaVikunja;
        mode = "0400";
        restartUnits = [ "pocket-id-vikunja-client.service" ];
      };
    };

    templates = {
      "pocket-id-api-key.header" = {
        content = "X-API-Key: ${config.sops.placeholder.pocket-id-static-api-key}";
        mode = "0400";
        restartUnits = [ "pocket-id-vikunja-client.service" ];
      };

      "pocket-id-vikunja.env" = {
        content = "STATIC_API_KEY=${config.sops.placeholder.pocket-id-static-api-key}";
        mode = "0400";
        restartUnits = [ "pocket-id.service" ];
      };
    };
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
        image = image;

        networks = [ config.virtualisation.quadlet.networks.auth.ref ];

        networkAliases = [ "pocket-id" ];

        environments = {
          APP_URL = "https://auth.mvanderloo.com";

          # Only connect trusted services to the auth network.
          TRUST_PROXY = "true";

          # Explicitly keep SQLite inside the persistent bind mount.
          DB_CONNECTION_STRING = "/pocket-id/var/pocket-id.db";

          ENCRYPTION_KEY_FILE = "/run/secrets/pocket-id-encryption-key";
        };

        environmentFiles = [ config.sops.templates."pocket-id-vikunja.env".path ];

        volumes = [
          "/var/lib/pocket-id:/pocket-id/var"
          "${encryptionKey.path}:/run/secrets/pocket-id-encryption-key:ro"
        ];

        publishPorts = [ "127.0.0.1:1411:1411" ];

        readOnly = true;
        noNewPrivileges = true;
        dropCapabilities = [ "ALL" ];

        # Retain the image's built-in health command.
        healthCmd = ''["CMD","/usr/local/bin/pocket-id","healthcheck"]'';
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

  systemd.services.pocket-id-vikunja-client = {
    description = "Provision Vikunja's Pocket ID client";
    wantedBy = [ "multi-user.target" ];
    requires = [ "pocket-id.service" ] ++ secretUnits;
    after = [ "pocket-id.service" ] ++ secretUnits;

    script = ''
      set -euo pipefail

      ${pkgs.curl}/bin/curl \
        --fail \
        --silent \
        --show-error \
        --retry 30 \
        --retry-all-errors \
        --retry-connrefused \
        --retry-delay 2 \
        http://127.0.0.1:1411/healthz \
        >/dev/null

      status="$(${pkgs.curl}/bin/curl \
        --header "@${config.sops.templates."pocket-id-api-key.header".path}" \
        --output /dev/null \
        --silent \
        --write-out '%{http_code}' \
        "${apiUrl}/${clientId}" || true)"

      case "$status" in
        200)
          ${pkgs.curl}/bin/curl \
            --data-binary "@${clientUpdate}" \
            --fail-with-body \
            --header "@${config.sops.templates."pocket-id-api-key.header".path}" \
            --header 'Content-Type: application/json' \
            --request PUT \
            --silent \
            --show-error \
            "${apiUrl}/${clientId}" \
            >/dev/null
          ;;
        404)
          ${pkgs.curl}/bin/curl \
            --data-binary "@${clientCreate}" \
            --fail-with-body \
            --header "@${config.sops.templates."pocket-id-api-key.header".path}" \
            --header 'Content-Type: application/json' \
            --request POST \
            --silent \
            --show-error \
            "${apiUrl}" \
            >/dev/null
          ;;
        *)
          echo "Pocket ID returned HTTP $status while looking up ${clientId}" >&2
          exit 1
          ;;
      esac

      secret_prefix="$(${pkgs.coreutils}/bin/head -c 4 ${vikunjaClientSecret.path})"
      if ${pkgs.curl}/bin/curl \
        --fail-with-body \
        --header "@${config.sops.templates."pocket-id-api-key.header".path}" \
        --silent \
        --show-error \
        "${apiUrl}/${clientId}/secrets" \
        | ${pkgs.jq}/bin/jq \
          --exit-status \
          --arg prefix "$secret_prefix" \
          'any(.[]; .prefix == $prefix and .isActive)' \
          >/dev/null
      then
        exit 0
      fi

      ${pkgs.jq}/bin/jq \
        --null-input \
        --rawfile secret ${vikunjaClientSecret.path} \
        '{ secret: ($secret | rtrimstr("\n")) }' \
        | ${pkgs.curl}/bin/curl \
          --data-binary @- \
          --fail-with-body \
          --header "@${config.sops.templates."pocket-id-api-key.header".path}" \
          --header 'Content-Type: application/json' \
          --request POST \
          --silent \
          --show-error \
          "${apiUrl}/${clientId}/secrets" \
          >/dev/null
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  networking.firewall.interfaces."podman-auth" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
