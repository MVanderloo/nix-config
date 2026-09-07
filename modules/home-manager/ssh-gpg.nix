{ pkgs, ... }:
{
  imports = [ ./ssh-yubikey.nix ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  programs.gpg.enable = true;
}
