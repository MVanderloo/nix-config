{ config, pkgs, ... }:

{
  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      mosh
      podman-compose
      rayfish
      uv
    ];
  };

  programs = {
    atuin.settings.sync_address = "http://theta:8888";
    git.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    jujutsu.settings.user = {
      name = "Michael van der Loo";
      email = "me@mvanderloo.com";
    };
    ghostty = {
      settings = {
        config-file = "?${config.home.homeDirectory}/.config/ghostty/local";
      };
      systemd = {
        enable = true;
      };
    };
    home-manager.enable = true;
    pi-coding-agent.models.providers.ollama = {
      api = "openai-completions";
      apiKey = "ollama";
      # baseUrl = "http://localhost:8041/v1";
      baseUrl = "http://localhost:11434/v1";
      models = [
        { id = "qwen3.5:latest"; }
        { id = "gemma4:latest"; }
      ];
    };
    # ssh.settings."github.com".IdentityFile = "~/.ssh/id_ed25519";
  };
}
