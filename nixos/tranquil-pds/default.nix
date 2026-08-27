{
  config,
  pkgs,
  ...
}:
let
  hostname = "pds.mvanderloo.com";
  acmeEmail = "admin@mvanderloo.com";
  pdsPort = 3000;
  httpPort = 80;
  httpsPort = 443;
  dataDir = "/var/lib/tranquil-pds";
  networkName = "tranquil";
  sopsFile = ../../hosts/theta/secrets.yaml;
in
{
  config = {
    sops.secrets = {
      "tranquil/jwt_secret" = {
        inherit sopsFile;
        restartUnits = [ "tranquil-config.service" ];
      };
      "tranquil/dpop_secret" = {
        inherit sopsFile;
        restartUnits = [ "tranquil-config.service" ];
      };
      "tranquil/master_key" = {
        inherit sopsFile;
        restartUnits = [ "tranquil-config.service" ];
      };
      "tranquil/db_password" = {
        inherit sopsFile;
        restartUnits = [ "tranquil-config.service" ];
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d ${dataDir} 0750 root root -"
        "d ${dataDir}/blobs 0750 root root -"
        "d ${dataDir}/store 0750 root root -"
        "d ${dataDir}/postgres 0750 root root -"
        "d ${dataDir}/certs 0750 root root -"
        "d ${dataDir}/acme 0750 root root -"
        "d ${dataDir}/nginx 0750 root root -"
      ];

      services = {
        tranquil-config = {
          description = "Generate Tranquil PDS config";
          wantedBy = [ "multi-user.target" ];
          before = [ "podman-tranquil-pds.service" ];
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
          script = ''
            cat > ${dataDir}/config.toml << TOML
            [server]
            hostname = "${hostname}"
            host = "[::]"
            port = ${toString pdsPort}
            invite_code_required = true

            [frontend]
            enabled = true

            [database]
            url = "postgresql://tranquil_pds:$(cat ${
              config.sops.secrets."tranquil/db_password".path
            })@tranquil-pds-db:5432/pds"

            [secrets]
            jwt_secret = "$(cat ${config.sops.secrets."tranquil/jwt_secret".path})"
            dpop_secret = "$(cat ${config.sops.secrets."tranquil/dpop_secret".path})"
            master_key = "$(cat ${config.sops.secrets."tranquil/master_key".path})"

            [storage]
            backend = "filesystem"
            path = "/var/lib/tranquil-pds/blobs"

            [tranquil_store]
            data_dir = "/var/lib/tranquil-pds/store"
            TOML
            chmod 600 ${dataDir}/config.toml
          '';
        };

        tranquil-nginx-config = {
          description = "Generate Tranquil nginx config";
          wantedBy = [ "multi-user.target" ];
          before = [ "podman-tranquil-nginx.service" ];
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
          script = ''
            mkdir -p ${dataDir}/nginx
            cat > ${dataDir}/nginx/nginx.conf << 'NGINX'
            worker_processes auto;
            error_log /var/log/nginx/error.log warn;
            pid /var/run/nginx.pid;

            events {
                worker_connections 4096;
                use epoll;
                multi_accept on;
            }

            http {
                include /etc/nginx/mime.types;
                default_type application/octet-stream;

                log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                                '$status $body_bytes_sent "$http_referer" '
                                '"$http_user_agent" "$http_x_forwarded_for" '
                                'rt=$request_time uct="$upstream_connect_time" '
                                'uht="$upstream_header_time" urt="$upstream_response_time"';

                access_log /var/log/nginx/access.log main;

                sendfile on;
                tcp_nopush on;
                tcp_nodelay on;
                keepalive_timeout 65;
                types_hash_max_size 2048;

                gzip on;
                gzip_vary on;
                gzip_proxied any;
                gzip_comp_level 6;
                gzip_types text/plain text/css text/xml application/json application/javascript
                           application/xml application/xml+rss text/javascript application/activity+json;

                ssl_protocols TLSv1.2 TLSv1.3;
                ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
                ssl_prefer_server_ciphers off;
                ssl_session_cache shared:SSL:10m;
                ssl_session_timeout 1d;
                ssl_session_tickets off;
                ssl_stapling on;
                ssl_stapling_verify on;

                upstream pds {
                    server tranquil-pds:${toString pdsPort};
                    keepalive 32;
                }

                server {
                    listen 80;
                    listen [::]:80;
                    server_name {{hostname}} *.{{hostname}};

                    location /.well-known/acme-challenge/ {
                        root /var/www/acme;
                    }

                    location / {
                        return 301 https://$host$request_uri;
                    }
                }

                server {
                    listen 443 ssl;
                    listen [::]:443 ssl;
                    http2 on;
                    server_name {{hostname}} *.{{hostname}};

                    ssl_certificate /etc/nginx/certs/live/{{hostname}}/fullchain.pem;
                    ssl_certificate_key /etc/nginx/certs/live/{{hostname}}/privkey.pem;

                    client_max_body_size 10G;

                    proxy_http_version 1.1;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;

                    location /xrpc/ {
                        proxy_pass http://pds;
                        proxy_set_header Upgrade $http_upgrade;
                        proxy_set_header Connection "upgrade";
                        proxy_read_timeout 86400;
                        proxy_send_timeout 86400;
                        proxy_buffering off;
                        proxy_request_buffering off;
                    }

                    location /oauth/ {
                        proxy_pass http://pds;
                        proxy_read_timeout 300;
                        proxy_send_timeout 300;
                    }

                    location / {
                        proxy_pass http://pds;
                    }
                }
            }
            NGINX
            sed -i "s/{{hostname}}/${hostname}/g" ${dataDir}/nginx/nginx.conf
          '';
        };
        podman-network-tranquil = {
          description = "Tranquil PDS podman network";
          wantedBy = [ "multi-user.target" ];
          before = [
            "podman-tranquil-pds-db.service"
            "podman-tranquil-pds.service"
            "podman-tranquil-nginx.service"
            "podman-tranquil-certbot.service"
          ];
          path = [ pkgs.podman ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            podman network exists ${networkName} || podman network create ${networkName}
          '';
        };
        tranquil-certbot-init = {
          description = "Obtain initial TLS certificate for Tranquil PDS";
          wantedBy = [ "multi-user.target" ];
          before = [ "podman-tranquil-nginx.service" ];
          after = [
            "tranquil-nginx-config.service"
            "podman-network-tranquil.service"
          ];
          requires = [ "tranquil-nginx-config.service" ];
          serviceConfig.Type = "oneshot";
          path = [ pkgs.podman ];
          script = ''
            if [ ! -d "${dataDir}/certs/live/${hostname}" ]; then
              podman run --rm \
                --network=${networkName} \
                -v ${dataDir}/certs:/etc/letsencrypt \
                -v ${dataDir}/acme:/var/www/acme \
                docker.io/certbot/certbot:v5.2.2 \
                certonly --webroot -w /var/www/acme \
                -d ${hostname} -d '*.${hostname}' \
                --email ${acmeEmail} --agree-tos --non-interactive
            fi
          '';
        };
        podman-tranquil-pds = {
          after = [ "tranquil-config.service" ];
          requires = [ "tranquil-config.service" ];
        };
        podman-tranquil-nginx = {
          after = [ "tranquil-nginx-config.service" ];
          requires = [ "tranquil-nginx-config.service" ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      httpPort
      httpsPort
    ];
  };
}
