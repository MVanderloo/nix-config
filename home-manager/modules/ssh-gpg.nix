{ pkgs, lib, ... }:
{
  imports = [ ./ssh.nix ];

  services.ssh-agent.enable = lib.mkForce false;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  programs.gpg.enable = true;
}