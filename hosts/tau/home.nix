{
  config,
  pkgs,
  sshPublicKeys,
  ...
}:

{
  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    file.".ssh/authorized_keys" = {
      force = true;
      text = "${sshPublicKeys.yubikey}\n";
    };

    packages = with pkgs; [
      devenv
      rayfish
      vesktop
    ];

    sessionVariables.LOCAL_KEY = "${config.xdg.configHome}/nix/alpha-deploy.sec";
  };

  programs = {
    atuin.settings.sync_address = "http://theta:8888";
    docker-cli.enable = true;
    git.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    home-manager.enable = true;
    jujutsu.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    nh.flake = "${config.home.homeDirectory}/Repositories/nix-config";
    # ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };

  services.syncthing.deviceName = "tau";
}
