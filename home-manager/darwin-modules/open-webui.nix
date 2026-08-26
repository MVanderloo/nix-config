{ config, pkgs, ... }:
let
  dataDir = "${config.xdg.dataHome}/open-webui";
in
{
  home.packages = [ pkgs.open-webui ];

  launchd.agents.open-webui = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.open-webui}/bin/open-webui"
        "serve"
        "--host"
        "127.0.0.1"
        "--port"
        "3000"
      ];

      EnvironmentVariables = {
        WEBUI_SECRET_KEY = "a1fb890f7ccfec5314f60e02e32fd1bcfbe00aa1261ef4cf3cead40a127b1072";
        DATA_DIR = "${config.home.homeDirectory}/.local/share/open-webui";
      };

      WorkingDirectory = dataDir;

      KeepAlive = true;
      RunAtLoad = true;

      StandardOutPath = "/tmp/open-webui.log";
      StandardErrorPath = "/tmp/open-webui.err.log";
    };
  };
}
