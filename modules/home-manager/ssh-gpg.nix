{ pkgs, lib, ... }:
{
  imports = [ ./ssh.nix ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = lib.mkDefault pkgs.pinentry-curses;
  };

  programs.gpg.enable = true;
}
