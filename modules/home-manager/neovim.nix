{ pkgs, ... }:

let
  select-undo-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "select-undo.nvim";
    version = "0-unstable-2026-07-05";

    src = pkgs.fetchFromGitHub {
      owner = "sunnytamang";
      repo = "select-undo.nvim";
      rev = "d3e9658f8dbcbf67267f5d07505917543beac376";
      hash = "sha256-mzSEyYEg4UQ8UCW4dAGooSlB9sSKS9PLu4gGJQZPV5E=";
    };
  };
in

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

    plugins =
      (with pkgs.vimPlugins; [
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
      ])
      ++ [ select-undo-nvim ];

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
