{ config, lib, pkgs, ... }:
let
  cfg = config.services.llama-swap;
  yaml = pkgs.formats.yaml { };
  configFile = yaml.generate "llama-swap.yaml" {
    models = builtins.mapAttrs (_name: model: {
      cmd = "${pkgs.llama-cpp}/bin/llama-server --model ${model.file} --port ${toString model.port} -ngl ${toString model.ngl}";
      proxy = "http://127.0.0.1:${toString model.port}";
    }) cfg.models;
    healthcheckTimeout = 600;
  };
in
{
  options.services.llama-swap = {
    enable = lib.mkEnableOption "llama-swap — hot-swap proxy for llama.cpp models";
    listen = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:8041";
      description = "Address and port to listen on";
    };
    models = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          file = lib.mkOption {
            type = lib.types.path;
            description = "Path to the .gguf model file";
          };
          port = lib.mkOption {
            type = lib.types.port;
            description = "Port for llama-server to listen on";
          };
          ngl = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 99;
            description = "Number of GPU layers to offload";
          };
        };
      });
      default = { };
      description = "Model definitions for llama-swap";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "DEPRECATED: home-manager cannot manage firewalls";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file."models/.keep".text = "";
    home.packages = [ pkgs.llama-swap pkgs.llama-cpp ];

    systemd.user.services.llama-swap = {
      Unit = {
        Description = "llama-swap model proxy";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = "${pkgs.llama-swap}/bin/llama-swap -config ${configFile} -listen ${cfg.listen}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}