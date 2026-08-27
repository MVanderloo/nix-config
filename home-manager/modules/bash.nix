{ config, lib, ... }:
{
  imports = [ ./shell.nix ];

  # Make sure the history directory exists before bash tries to write to it
  home.activation.createBashHistoryDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.xdg.stateHome}/bash"
  '';

  programs = {
    bash = {
      enable = true;

      historyControl = [
        "erasedups"
        "ignoredups"
      ];
      historyFile = "${config.xdg.stateHome}/bash/history";
      historyFileSize = 100000;
      historySize = 100000;

      shellOptions = [
        "histappend"
        "extglob"
        "globstar"
        "dirspell"
      ];

      initExtra = ''
        cd() {
          builtin cd "$@" && ls
        }
      '';
    };
    dircolors.enableBashIntegration = true;
    direnv.enableBashIntegration = true;
    ghostty.enableBashIntegration = true;
    starship.enableBashIntegration = true;
    yazi.enableBashIntegration = true;
    zoxide.enableBashIntegration = true;
  };

}
