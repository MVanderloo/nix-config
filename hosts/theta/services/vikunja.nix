{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:

let
  stateDirectory = "/var/lib/vikunja";
  port = 3456;
  publicUrl = "https://todo.mvanderloo.com";
  backendUrl = "http://127.0.0.1:${toString port}";
  secretUnits = lib.optional config.sops.useSystemdActivation "sops-install-secrets.service";
  image = "docker.io/vikunja/vikunja:2.6.0@sha256:417ada6f94e81f0267aa2f007d0a811fc82d38dd2aa58351e3ea520ca01c2ea5";
in
{
  sops = {
    secrets = {
      vikunja-oidc-client-secret = {
        sopsFile = secrets.thetaVikunja;
        restartUnits = [ "vikunja.service" ];
      };

      vikunja-service-secret = {
        sopsFile = secrets.thetaVikunja;
        restartUnits = [ "vikunja.service" ];
      };
    };

    templates."vikunja-config.yml" = {
      content = ''
        service:
          publicurl: ${publicUrl}
          enableregistration: false
          enablelinksharing: false
          timezone: ${config.time.timeZone}
          secret: ${config.sops.placeholder.vikunja-service-secret}
        auth:
          local:
            enabled: false
          openid:
            enabled: true
            redirecturl: ${publicUrl}/auth/openid/pocketid
            providers:
              pocketid:
                name: Pocket ID
                authurl: https://id.mvanderloo.com
                clientid: vikunja
                clientsecret: ${config.sops.placeholder.vikunja-oidc-client-secret}
                scope: openid profile email
                forceuserinfo: false
      '';
      uid = 1000;
      gid = 1000;
      mode = "0400";
      restartUnits = [ "vikunja.service" ];
    };
  };

  virtualisation.quadlet.containers.vikunja = {
    autoStart = true;

    unitConfig = {
      Description = "Vikunja issue tracker";
      After = [ "systemd-tmpfiles-setup.service" ] ++ secretUnits;
      Requires = secretUnits;
      RequiresMountsFor = [ stateDirectory ];
    };

    containerConfig = {
      image = image;
      readOnly = true;
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];

      environments.TZ = config.time.timeZone;
      publishPorts = [ "127.0.0.1:${toString port}:3456" ];

      volumes = [
        "${stateDirectory}/db:/db"
        "${stateDirectory}/files:/app/vikunja/files"
        "${config.sops.templates."vikunja-config.yml".path}:/etc/vikunja/config.yml:ro"
      ];

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
      "d ${stateDirectory}/db 0700 1000 1000 -"
      "d ${stateDirectory}/files 0700 1000 1000 -"
      "Z ${stateDirectory} - 1000 1000 -"
    ];

    services.vikunja-tailscale-serve = {
      description = "Expose Vikunja to Caddy through Tailscale Serve";
      wantedBy = [ "multi-user.target" ];
      requires = [
        "tailscaled.service"
        "vikunja.service"
      ];
      after = [
        "tailscaled.service"
        "vikunja.service"
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
