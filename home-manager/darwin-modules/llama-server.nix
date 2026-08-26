{ config, pkgs, ... }:
let
  modelsDir = "${config.home.homeDirectory}/Models";
  models = {
    "Qwen2.5 0.5B" = {
      file = "qwen2.5-0.5b-q4.gguf";
      port = 8999;
    };
    "Qwen3.8 27B-UD-Q6_K_M" = {
      file = "Qwen3.8-27B-UD-Q6_K_M.gguf";
      port = 8998;
    };
    "Qwen3.8 27B-UD-Q4_K_M" = {
      file = "Qwen3.8-27B-UD-Q4_K_M.gguf";
      port = 8997;
    };
    "Qwen3.6 35B-A3B" = {
      file = "Qwen3.6-35B-A3B-UD-Q4_K_M.gguf";
      port = 8996;
      extraArgs = [
        "-c"
        "100000"
        "-fa"
        "on"
        "-np"
        "1"
        "--spec-type"
        "draft-mtp"
        "--spec-draft-n-max"
        "2"
      ];
    };
  };
  yaml = pkgs.formats.yaml { };
  mkCmd =
    m:
    let
      base = [
        "${pkgs.llama-cpp}/bin/llama-server"
        "--model"
        "${modelsDir}/${m.file}"
        "--port"
        (toString m.port)
        "-ngl"
        "99"
      ];
      args = base ++ (m.extraArgs or [ ]);
    in
    builtins.concatStringsSep " " args;

  configFile = yaml.generate "llama-swap.yaml" {
    models = builtins.mapAttrs (_: m: {
      cmd = mkCmd m;
      proxy = "http://127.0.0.1:${toString m.port}";
    }) models;
  };
in
{
  launchd.agents.llama-swap = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.llama-swap}/bin/llama-swap"
        "-config"
        "${configFile}"
        "-listen"
        ":8041"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/llama-swap.log";
      StandardErrorPath = "/tmp/llama-swap.err.log";
    };
  };
}
