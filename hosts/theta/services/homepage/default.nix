{ config, pkgs, ... }:

let
  image = "ghcr.io/gethomepage/homepage:v2.3.0@sha256:f820276654539cdc2cf0169f28188d135919a7984fad76d83d8d5ff1383f3705";
  atuinPort = 8888;
  port = 3000;
  tailscalePort = 8444;
  tailnetDomain = "bongo-sidemirror.ts.net";
  hostname = "${config.networking.hostName}.${tailnetDomain}";
  backendUrl = "http://127.0.0.1:${toString port}";
  wallpaper = ../../../../assets/wallpapers/catpuccin_landscape.png;
  yaml = pkgs.formats.yaml { };

  settings = {
    title = "Home";
    description = "Personal services and systems";
    theme = "dark";
    color = "slate";
    background = {
      image = "/images/background.png";
      opacity = 24;
    };
    cardBlur = "sm";
    headerStyle = "clean";
    iconStyle = "theme";
    hideVersion = true;
    disableIndexing = true;
    target = "_blank";
    useEqualHeights = true;
    quicklaunch = {
      provider = "duckduckgo";
      searchDescriptions = true;
      mobileButtonPosition = "bottom-right";
    };
    layout = [
      {
        Everyday = {
          style = "row";
          columns = 5;
          icon = "mdi-star-four-points-outline";
        };
      }
      {
        Infrastructure = {
          style = "row";
          columns = 4;
          icon = "mdi-server-outline";
        };
      }
      {
        Observability = {
          style = "row";
          columns = 3;
          icon = "mdi-chart-box-outline";
        };
      }
      {
        "Needs attention" = {
          style = "row";
          columns = 4;
          icon = "mdi-alert-circle-outline";
          initiallyCollapsed = true;
        };
      }
    ];
  };

  services = [
    {
      Everyday = [
        {
          Hermes = {
            icon = "mdi-forum-outline";
            href = "https://${hostname}";
            description = "AI workspace · theta";
          };
        }
        {
          "Home Assistant" = {
            icon = "home-assistant.svg";
            href = "http://${hostname}:8123";
            description = "Home automation · theta";
          };
        }
        {
          Vikunja = {
            icon = "vikunja.svg";
            href = "https://todo.mvanderloo.com";
            description = "Tasks and projects · theta";
          };
        }
        {
          FreshRSS = {
            icon = "freshrss.svg";
            href = "http://omega.${tailnetDomain}:8082";
            description = "Feeds and reading · omega";
          };
        }
        {
          "Shape of the Day" = {
            icon = "mdi-shape-outline";
            href = "http://omega.${tailnetDomain}:3000";
            description = "A small daily diversion · omega";
          };
        }
      ];
    }
    {
      Infrastructure = [
        {
          "Pocket ID" = {
            icon = "mdi-shield-key-outline";
            href = "https://auth.mvanderloo.com";
            description = "Passkeys and identity · alpha";
          };
        }
        {
          Arcane = {
            icon = "mdi-cube-outline";
            href = "http://omega.${tailnetDomain}:3552";
            description = "Container management · omega";
          };
        }
        {
          Syncthing = {
            icon = "syncthing.svg";
            href = "http://omega.${tailnetDomain}:8384";
            description = "File synchronization · omega";
          };
        }
        {
          Atuin = {
            icon = "atuin.svg";
            href = "http://${hostname}:${toString atuinPort}";
            description = "Shell history sync · theta";
          };
        }
      ];
    }
    {
      Observability = [
        {
          "Hermes Dashboard" = {
            icon = "mdi-robot-outline";
            href = "https://${hostname}:9443";
            description = "Agent operations · theta";
          };
        }
        {
          "Omega Homepage" = {
            icon = "homepage.png";
            href = "https://omega.${tailnetDomain}";
            description = "Fallback dashboard · omega";
          };
        }
        {
          "Rayfish Metrics" = {
            icon = "mdi-chart-timeline-variant";
            href = "http://delta.${tailnetDomain}:9090";
            description = "Prometheus endpoint · delta";
          };
        }
      ];
    }
    {
      "Needs attention" = [
        {
          "Personal Website" = {
            id = "attention-personal-site";
            icon = "mdi-web-off";
            href = "https://mvanderloo.com";
            description = "Repair Caddy upstream · HTTP 404";
          };
        }
        {
          "Hermes Dashboard (Delta)" = {
            id = "attention-hermes-delta";
            icon = "mdi-robot-off-outline";
            href = "https://delta.${tailnetDomain}";
            description = "Restore backend · HTTP 502";
          };
        }
        {
          "Syncthing (Delta)" = {
            id = "attention-syncthing-delta";
            icon = "mdi-sync-alert";
            href = "http://delta.${tailnetDomain}:8384";
            description = "Expose GUI to the tailnet";
          };
        }
        {
          "Syncthing (Tau)" = {
            id = "attention-syncthing-tau";
            icon = "mdi-sync-alert";
            href = "http://tau.${tailnetDomain}:8384";
            description = "Verify GUI when tau is online";
          };
        }
      ];
    }
  ];

  widgets = [
    {
      greeting = {
        text = "mv / home";
        text_size = "2xl";
      };
    }
    {
      search = {
        provider = "duckduckgo";
        target = "_blank";
      };
    }
    {
      datetime = {
        text_size = "xl";
        format = {
          dateStyle = "medium";
          timeStyle = "short";
        };
      };
    }
  ];

  configFiles = {
    "settings.yaml" = yaml.generate "settings.yaml" settings;
    "services.yaml" = yaml.generate "services.yaml" services;
    "bookmarks.yaml" = yaml.generate "bookmarks.yaml" [ ];
    "widgets.yaml" = yaml.generate "widgets.yaml" widgets;
    "docker.yaml" = yaml.generate "docker.yaml" { };
    "kubernetes.yaml" = yaml.generate "kubernetes.yaml" { };
    "proxmox.yaml" = yaml.generate "proxmox.yaml" { };
    "custom.css" = ./homepage.css;
    "custom.js" = pkgs.writeText "custom.js" "";
  };

  # Copy files rather than linking: store symlink targets aren't in the container.
  configDirectory = pkgs.runCommand "homepage-config" { } (
    "mkdir -p $out\n"
    + pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (name: file: "cp ${file} $out/${name}") configFiles
    )
  );
in
{
  virtualisation.quadlet.containers.homepage = {
    autoStart = true;

    unitConfig.Description = "Homepage dashboard";

    containerConfig = {
      image = image;
      user = "1000:1000";
      readOnly = true;
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];

      environments = {
        HOMEPAGE_ALLOWED_HOSTS = "${hostname}:${toString tailscalePort}";
        HOSTNAME = "0.0.0.0";
        LOG_TARGETS = "stdout";
        TZ = config.time.timeZone;
      };

      publishPorts = [ "127.0.0.1:${toString port}:3000" ];
      volumes = [
        "${configDirectory}:/app/config:ro"
        "${wallpaper}:/app/public/images/background.png:ro"
      ];
      tmpfses = [
        "/app/.next/cache:U,mode=0700"
        # Homepage rewrites its prerendered settings during revalidation.
        "/app/.next/server/pages:U,mode=0700"
        "/tmp:U,mode=0700"
      ];
    };

    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
      TimeoutStartSec = "900s";
    };
  };

  systemd.services.homepage-tailscale-serve = {
    description = "Expose Homepage through Tailscale Serve";
    wantedBy = [ "multi-user.target" ];
    requires = [
      "tailscaled.service"
      "homepage.service"
    ];
    after = [
      "tailscaled.service"
      "homepage.service"
    ];

    script = ''
      # Apply settings.yaml before exposing the freshly started container.
      ${pkgs.curl}/bin/curl \
        --fail \
        --silent \
        --show-error \
        --retry 30 \
        --retry-all-errors \
        --retry-delay 1 \
        --max-time 5 \
        --header 'Host: ${hostname}:${toString tailscalePort}' \
        --request POST \
        ${backendUrl}/api/revalidate \
        >/dev/null

      ${pkgs.tailscale}/bin/tailscale serve \
        --yes \
        --bg \
        --https=${toString tailscalePort} \
        --set-path=/ \
        ${backendUrl}
    '';

    preStop = ''
      ${pkgs.tailscale}/bin/tailscale serve \
        --yes \
        --https=${toString tailscalePort} \
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
}
