{ lib, pkgs, ... }:
{
  imports = [ ./ssh.nix ];

  services.ssh-agent.enable = lib.mkForce false;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  programs.gpg.enable = true;
}
