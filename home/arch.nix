{
  imports = [ ./common.nix ];

  home = {
    username = "mv";
    homeDirectory = "/home/mv";
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
