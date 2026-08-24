{ pkgs, ... }:
{
  home.packages = with pkgs; [ openssh ];

  services.ssh-agent.enable = true;

  programs.ssh = {
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
      ControlMaster = "auto";
      ControlPath = "~/.ssh/master-%r@%h:%p";
      ControlPersist = "10m";
    };
  };
}
