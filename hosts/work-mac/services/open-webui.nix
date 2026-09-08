{
  config,
  lib,
  openWebui,
  ...
}:
let
  dataDir = "${config.xdg.dataHome}/open-webui";
  logDir = "${config.xdg.stateHome}/open-webui";
in
{
  home.packages = [ openWebui ];

  launchd.agents.open-webui = {
    enable = false;
    config = {
      ProgramArguments = [
        (lib.getExe openWebui)
        "serve"
        "--host"
        "127.0.0.1"
        "--port"
        "3000"
      ];

      EnvironmentVariables = {
        # TODO create new key and add to SOPS
        # WEBUI_SECRET_KEY = "a1fb890f7ccfec5314f60e02e32fd1bcfbe00aa1261ef4cf3cead40a127b1072";
        DATA_DIR = "${config.home.homeDirectory}/.local/share/open-webui";
      };

      WorkingDirectory = dataDir;

      KeepAlive = true;
      RunAtLoad = true;

      StandardOutPath = "${logDir}/stdout.log";
      StandardErrorPath = "${logDir}/stderr.log";
      Umask = 63;
    };
  };
}
