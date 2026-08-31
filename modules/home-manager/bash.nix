{ config, lib, ... }:

{
  imports = [ ./shell.nix ];

  # Home Manager generates these as traditional dotfiles. Keep the generated
  # files, but expose them through Bash's XDG paths instead of linking them in
  # the home directory.
  home.file = {
    ".bash_logout".enable = lib.mkForce false;
    ".bash_profile".enable = lib.mkForce false;
    ".bashrc".enable = lib.mkForce false;
    ".profile".enable = lib.mkForce false;
  };

  xdg.configFile = {
    "bash/bash_logout" = lib.mkIf (config.programs.bash.logoutExtra != "") {
      source = config.home.file.".bash_logout".source;
    };
    "bash/bashrc".source = config.home.file.".bashrc".source;
    "bash/profile".source = config.home.file.".profile".source;
  };

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
