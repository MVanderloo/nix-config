{ config, pkgs, ... }:
{
  imports = [
    ./modules/cli.nix
    ./modules/editor.nix
    ./modules/pi.nix
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
      rayfish
      uv
    ];
  };

  programs = {
    atuin.settings.sync_address = "http:omega:8888";
    git.includes = [ { path = "${config.home.homeDirectory}/.config/git/local"; } ];
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
  };
}
