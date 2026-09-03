{ config, pkgs, ... }:

{
  home = {
    stateVersion = "26.05";
    username = "mv";
    homeDirectory = "/home/mv";

    packages = with pkgs; [
      codex
      maki
      mosh
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

  nixpkgs.config = {
    allowUnfreePackages = [ "nvidia-x11" ];
    nvidia.acceptLicense = true;
  };

  targets.genericLinux.gpu = {
    enable = true;
    nvidia = {
      enable = true;
      version = "610.57.04";
      sha256 = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
    };
  };
}
