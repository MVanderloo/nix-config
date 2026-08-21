{ pkgs, ... }:
{
  imports = [
    ./modules/editor.nix
    ./modules/fish.nix
    ./modules/pi.nix
    ./modules/python.nix
    ./modules/shell.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/version-control.nix
    ./modules/xdg.nix
  ];

  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      maki
      podman-compose
      rayfish
      uv
    ];
  };

  programs = {
    atuin.settings.sync_address = "http:omega:8888";
    git.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    jujutsu.settings.user = {
      email = "me@mvanderloo.com";
      name = "Michael van der Loo";
    };
    home-manager.enable = true;
    pi-coding-agent.models.providers.ollama = {
      api = "openai-completions";
      apiKey = "ollama";
      baseUrl = "http://localhost:11434/v1";
      models = [
        { id = "qwen3.5:latest"; }
        { id = "gemma4:latest"; }
      ];
    };
    ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };

  services.podman.enable = true;
}
