{ pkgs, ... }:

{
  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      mini-nvim

      blink-cmp
      blink-ripgrep-nvim
      bullets-vim
      colorful-menu-nvim
      conform-nvim
      csvview-nvim
      friendly-snippets
      fyler-nvim
      gitsigns-nvim
      guess-indent-nvim
      helpview-nvim
      indent-blankline-nvim
      lualine-nvim
      markview-nvim
      neovim-ayu
      nvim-lspconfig
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
      oil-nvim
      quicker-nvim
      SchemaStore-nvim
      tiny-inline-diagnostic-nvim
      treesj
    ];

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
