{ pkgs, config, ... }:

{
  imports = [
    ../../modules/home-manager/darwin/aerospace.nix
    ../../modules/home-manager/darwin/ghostty.nix
    ../../modules/home-manager/darwin/llama-server.nix
    ../../modules/home-manager/darwin/open-webui.nix
    ../../modules/home-manager/darwin/tmux.nix
    ../../modules/home-manager/editor.nix
    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/python.nix
    ../../modules/home-manager/version-control.nix
    ../../modules/home-manager/xdg.nix
  ];

  home = {
    stateVersion = "26.05";
    username = "mi30175";
    homeDirectory = "/Users/mi30175";
    shellAliases = {
      copy = "pbcopy";
    };

    packages = with pkgs; [
      awscli2
      clickhouse
      devenv
      duckdb
      nodejs_22
      parquet-tools
      podman
      podman-compose
      python3Packages.huggingface-hub
      uv
      # fonts
      monocraft
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.monaspace
    ];
  };

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      pinentry.package = pkgs.pinentry_mac;
    };
    podman.enable = true;
    tldr-update.enable = true;
  };

  programs = {
    fish.interactiveShellInit = ''
      for f in ~/.local/env/*.env
        test -f $f; or continue
        for line in (cat $f | grep -v '^#' | grep '=')
          set -gx (string split -m1 '=' $line)
        end
      end
    '';
    git.includes = [ { path = "${config.home.homeDirectory}/.config/git/local"; } ];
    ghostty.settings.config-file = "?${config.home.homeDirectory}/.config/ghostty/local";
    gpg.enable = true;
    keepassxc.enable = true;
    nh.flake = "/Users/mi30175/Repositories/nix-config";
    ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };
}
