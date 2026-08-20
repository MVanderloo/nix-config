{ pkgs, config, ... }:

{
  imports = [
    ./darwin-modules/aerospace.nix
    ./darwin-modules/ghostty.nix
    ./darwin-modules/llama-server.nix
    ./modules/editor.nix
    ./modules/fish.nix
    ./modules/python.nix
    ./modules/tmux.nix
    ./modules/version-control.nix
    ./modules/xdg.nix
  ];

  home = {
    stateVersion = "26.05";
    username = "mi30175";
    homeDirectory = "/Users/mi30175";
    shellAliases = {
      copy = "pbcopy";
    };

    packages = with pkgs; [
      # docker
      # docker-compose
      awscli2
      clickhouse
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
    # colima.enable = true;
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      # enableSshSupport = true;
      pinentry.package = pkgs.pinentry_mac;
    };
    podman.enable = true;
    tldr-update.enable = true;
  };

  programs = {
    # docker-cli.enable = true;
    fish.interactiveShellInit = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
    bash.initExtra = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
    git.includes = [ { path = "${config.home.homeDirectory}/.config/git/local"; } ];
    ghostty.settings.config-file = "?${config.home.homeDirectory}/.config/ghostty/local";
    gpg.enable = true;
  };
}
