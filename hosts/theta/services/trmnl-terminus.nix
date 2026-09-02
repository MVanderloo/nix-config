{
  config,
  pkgs,
  ...
}:

let
  stateDirectory = "/var/lib/trmnl-terminus";
  environmentFile = "${stateDirectory}/terminus.env";
  network = "trmnl-terminus";
  port = 2300;
  lanInterfaces = [
    "eno1"
    "wlp1s0"
  ];
  lanUrl = "http://${config.networking.hostName}.local:${toString port}";
  terminusImage = "ghcr.io/usetrmnl/terminus:0.60.0@sha256:48f78aec134e67c121c703b79cc6d15f722fa3a00d1438934817a61d4daab5c1";

  commonEnvironment = {
    API_URI = lanUrl;
    HANAMI_PORT = toString port;
    TZ = config.time.timeZone;
  };
in
{
  services.avahi = {
    enable = true;
    allowInterfaces = lanInterfaces;
    nssmdns4 = true;
    openFirewall = false;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  networking.firewall.interfaces = {
    eno1 = {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ 5353 ];
    };
    tailscale0.allowedTCPPorts = [ port ];
    wlp1s0 = {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ 5353 ];
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";

    containers = {
      trmnl-terminus-database = {
        image = "docker.io/library/postgres:18.4-alpine@sha256:9a8afca54e7861fd90fab5fdf4c42477a6b1cb7d293595148e674e0a3181de15";

        environment = {
          POSTGRES_DB = "terminus";
          POSTGRES_USER = "terminus";
        };
        environmentFiles = [ environmentFile ];

        extraOptions = [
          "--network=${network}"
          "--security-opt=no-new-privileges"
        ];
        pull = "missing";
        volumes = [ "trmnl-terminus-database:/var/lib/postgresql" ];
      };

      trmnl-terminus-keyvalue = {
        image = "docker.io/valkey/valkey:9-alpine@sha256:a174b894902bd3367e330d47cc2054367dc4917701776aaf336f41d83b65ec7a";

        cmd = [
          "sh"
          "-c"
          ''exec valkey-server --requirepass "$KEYVALUE_PASSWORD" --maxmemory 512mb --maxmemory-policy noeviction''
        ];
        environmentFiles = [ environmentFile ];

        extraOptions = [
          "--network=${network}"
          "--security-opt=no-new-privileges"
        ];
        pull = "missing";
        volumes = [ "trmnl-terminus-keyvalue:/data" ];
      };

      trmnl-terminus = {
        image = terminusImage;

        environment = commonEnvironment // {
          APP_SETUP = "true";
        };
        environmentFiles = [ environmentFile ];

        extraOptions = [
          "--init"
          "--network=${network}"
          "--security-opt=no-new-privileges"
          "--shm-size=1g"
        ];
        ports = [ "${toString port}:${toString port}/tcp" ];
        pull = "missing";
        volumes = [ "trmnl-terminus-uploads:/app/public/uploads" ];
      };

      trmnl-terminus-worker = {
        image = terminusImage;

        cmd = [
          "bundle"
          "exec"
          "sidekiq"
          "-r"
          "./config/sidekiq.rb"
        ];
        environment = commonEnvironment;
        environmentFiles = [ environmentFile ];

        extraOptions = [
          "--init"
          "--network=${network}"
          "--security-opt=no-new-privileges"
          "--shm-size=1g"
        ];
        pull = "missing";
        volumes = [ "trmnl-terminus-uploads:/app/public/uploads" ];
      };
    };
  };

  systemd = {
    tmpfiles.rules = [ "d ${stateDirectory} 0700 root root -" ];

    services = {
      trmnl-terminus-secrets = {
        description = "Generate persistent Terminus secrets";
        wantedBy = [ "multi-user.target" ];
        before = [
          "podman-trmnl-terminus-database.service"
          "podman-trmnl-terminus-keyvalue.service"
          "podman-trmnl-terminus.service"
          "podman-trmnl-terminus-worker.service"
        ];

        script = ''
          if [[ ! -s ${environmentFile} ]]; then
            umask 077
            app_secret="$(${pkgs.openssl}/bin/openssl rand -hex 80)"
            database_password="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
            keyvalue_password="$(${pkgs.openssl}/bin/openssl rand -hex 32)"

            printf '%s\n' \
              "APP_SECRET=$app_secret" \
              "DATABASE_PASSWORD=$database_password" \
              "DATABASE_URL=postgres://terminus:$database_password@trmnl-terminus-database:5432/terminus" \
              "KEYVALUE_PASSWORD=$keyvalue_password" \
              "KEYVALUE_URL=redis://:$keyvalue_password@trmnl-terminus-keyvalue:6379/0" \
              "POSTGRES_PASSWORD=$database_password" \
              > ${environmentFile}
          fi

          chmod 0400 ${environmentFile}
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };

      podman-network-trmnl-terminus = {
        description = "Podman network for Terminus";
        wantedBy = [ "multi-user.target" ];

        script = ''
          if ! ${pkgs.podman}/bin/podman network exists ${network}; then
            ${pkgs.podman}/bin/podman network create ${network}
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "-${pkgs.podman}/bin/podman network rm ${network}";
        };
      };

      podman-trmnl-terminus-database = {
        requires = [
          "podman-network-trmnl-terminus.service"
          "trmnl-terminus-secrets.service"
        ];
        after = [
          "podman-network-trmnl-terminus.service"
          "trmnl-terminus-secrets.service"
        ];
      };

      podman-trmnl-terminus-keyvalue = {
        requires = [
          "podman-network-trmnl-terminus.service"
          "trmnl-terminus-secrets.service"
        ];
        after = [
          "podman-network-trmnl-terminus.service"
          "trmnl-terminus-secrets.service"
        ];
      };

      podman-trmnl-terminus = {
        requires = [
          "podman-trmnl-terminus-database.service"
          "podman-trmnl-terminus-keyvalue.service"
        ];
        after = [
          "podman-trmnl-terminus-database.service"
          "podman-trmnl-terminus-keyvalue.service"
        ];

        preStart = ''
          for attempt in $(${pkgs.coreutils}/bin/seq 1 30); do
            if ${pkgs.podman}/bin/podman exec trmnl-terminus-database \
                pg_isready --username terminus --dbname terminus >/dev/null \
              && [[ "$(${pkgs.podman}/bin/podman exec trmnl-terminus-keyvalue \
                sh -c 'valkey-cli --no-auth-warning -a "$KEYVALUE_PASSWORD" ping')" == PONG ]]; then
              exit 0
            fi

            ${pkgs.coreutils}/bin/sleep 2
          done

          echo "Terminus dependencies did not become healthy in time" >&2
          exit 1
        '';
      };

      podman-trmnl-terminus-worker = {
        requires = [ "podman-trmnl-terminus.service" ];
        after = [ "podman-trmnl-terminus.service" ];
      };
    };
  };

  preservation.preserveAt."/persist".directories = [ stateDirectory ];
}
