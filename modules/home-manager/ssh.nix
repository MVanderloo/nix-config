{ pkgs, yubikeySshKey, ... }:

let
  yubikeyIdentity = {
    IdentitiesOnly = true;
    IdentityFile = "~/.ssh/yubikey.pub";
  };
in
{
  home.packages = with pkgs; [ openssh ];

  home.file.".ssh/yubikey.pub".text = "${yubikeySshKey}\n";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "no";
        Compression = true;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%h:%p";
        ControlPersist = "10m";
        ForwardAgent = false;
        HashKnownHosts = false;
        ServerAliveCountMax = 3;
        ServerAliveInterval = 0;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };

      "github.com" = yubikeyIdentity;
    };
  };
}
