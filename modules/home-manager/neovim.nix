{ pkgs, ... }:

{
  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };

  # home = {
  #   shellAliases = {
  #     vim = "nvim";
  #     vimdiff = "nvim -d";
  #   };
  #
  #   sessionVariables = {
  #     EDITOR = "nvim";
  #     VISUAL = "nvim";
  #   };
  # };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      curl
      fd
      gcc
      git
      ripgrep
      tree-sitter

      # LSPs
      ansible-language-server
      awk-language-server
      bash-language-server
      docker-compose-language-service
      docker-language-server
      emmylua-ls
      fish-lsp
      gopls
      jq-lsp
      just-lsp
      nixd
      postgres-language-server
      # roc
      ruff
      rust-analyzer
      systemd-lsp
      taplo
      tinymist
      ty
      vscode-langservers-extracted
      yaml-language-server
      zls

      # Formatters
      clang-tools
      dockerfmt
      fish
      gawk
      gotools
      just
      nixfmt
      prettier
      rustfmt
      shfmt
      sqruff
      stylua
      typst
      yamlfix
    ];
  };
}
