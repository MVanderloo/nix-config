{ pkgs, ... }:

{
  imports = [
    ./home.nix

    ../../modules/home-manager/codex.nix
    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/ghostty.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/ssh-gpg.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/tailscale-ssh.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/tsshd.nix
    ../../modules/home-manager/version-control.nix
    ../../modules/home-manager/xdg.nix
  ];

  nix = {
    package = pkgs.nix;
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "delta";
        protocol = "ssh-ng";
        sshUser = "mv";
        systems = [ "x86_64-linux" ];
        maxJobs = 8;
        speedFactor = 2;
      }
      {
        hostName = "theta";
        protocol = "ssh-ng";
        sshUser = "mv";
        systems = [ "x86_64-linux" ];
        maxJobs = 8;
      }
    ];
    settings.builders-use-substitutes = true;
  };
}
