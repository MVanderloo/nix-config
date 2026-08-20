{ config, pkgs, ... }:
let
  configFile = pkgs.writeText "llama-swap.yaml" ''
    models:
      "qwen2.5-0.5b":
        cmd: >
          ${pkgs.llama-cpp}/bin/llama-server
          --model ${config.home.homeDirectory}/models/qwen2.5-0.5b-q4.gguf
          --port 8999
          -ngl 99
        proxy: "http://127.0.0.1:8999"
  '';
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
