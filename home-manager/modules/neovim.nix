{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      # Runtime
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
      just-lsp
      jq-lsp
      nixd
      postgres-language-server
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
      roc
      rustfmt
      shfmt
      sqruff
      stylua
      typst
      yamlfix
      zig
    ];
  };

  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };
}
