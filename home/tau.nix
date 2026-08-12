{
  imports = [
    ../home/modules/cli.nix
    ../home/modules/editor.nix
    ../home/modules/shell.nix
    ../home/modules/ssh.nix
    ../home/modules/tmux.nix
    ../home/modules/version-control.nix
    ../home/modules/xdg.nix
  ];

  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";
  };

  programs = {
    atuin.settings.sync_address = "http:omega:8888";
    docker-cli.enable = true;
    home-manager.enable = true;
  };
}
