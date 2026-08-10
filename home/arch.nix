{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  home = {
    username = "mv";
    homeDirectory = "/home/mv";

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    # file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    # };

    # sessionVariables = {
    #   # EDITOR = "emacs";
    # };

    # packages = with pkgs; [
    # ];
  };

  programs = {
    atuin = {
      settings = {
        sync_address = "http:omega:8888";
      };
    };
    docker-cli.enable = true;
    home-manager.enable = true;
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        ForwardAgent = true;
        AddKeysToAgent = "yes";
        Compression = true;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "yes";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };

  services = {
    syncthing.enable = false;
  };
}
