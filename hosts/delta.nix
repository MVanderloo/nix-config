{ pkgs, config, ... }:
{
  imports = [
    ../modules/home-manager/editor.nix
    ../modules/home-manager/fish.nix
    ../modules/home-manager/ghostty.nix
    ../modules/home-manager/pi.nix
    ../modules/home-manager/python.nix
    ../modules/home-manager/shell.nix
    ../modules/home-manager/ssh-gpg.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/version-control.nix
    ../modules/home-manager/xdg.nix
  ];

  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      codex
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

  # services.llama-swap = {
  #   enable = true;
  #   listen = "0.0.0.0:8041";
  #   models = {
  #     # Download .gguf files to ~/models/ first
  #     # qwen3.5 = { file = "${config.home.homeDirectory}/models/qwen3.5.gguf"; port = 8999; };
  #     # gemma4 = { file = "${config.home.homeDirectory}/models/gemma4.gguf"; port = 8998; };
  #   };
  # };

  services.podman.enable = true;
}
