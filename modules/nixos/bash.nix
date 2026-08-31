{ lib, ... }:

{
  programs.bash = {
    enable = true;

    loginShellInit = ''
      bashConfigHome="''${XDG_CONFIG_HOME:-$HOME/.config}/bash"
      if [[ -r "$bashConfigHome/profile" ]]; then
        . "$bashConfigHome/profile"
      fi
      unset bashConfigHome
    '';

    interactiveShellInit = ''
      bashConfigHome="''${XDG_CONFIG_HOME:-$HOME/.config}/bash"
      if [[ -r "$bashConfigHome/bashrc" ]]; then
        . "$bashConfigHome/bashrc"
      fi
      unset bashConfigHome
    '';

    logout = lib.mkBefore ''
      bashConfigHome="''${XDG_CONFIG_HOME:-$HOME/.config}/bash"
      if [[ -r "$bashConfigHome/bash_logout" ]]; then
        . "$bashConfigHome/bash_logout"
      fi
      unset bashConfigHome
    '';
  };
}
