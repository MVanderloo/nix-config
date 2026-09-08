{ sshPublicKeys, ... }:

{
  imports = [ ./ssh.nix ];

  home.file.".ssh/yubikey.pub".text = "${sshPublicKeys.yubikey}\n";

  programs.ssh.settings."github.com" = {
    IdentityFile = "~/.ssh/yubikey.pub";
  };
}
