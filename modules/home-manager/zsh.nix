{
  programs.zsh = {
    enable = true;

    autosuggestion = {
      enable = true;
      highlight = "fg=8";
    };
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      share = true;
      # path = "$HOME/.local/state/zsh/history";
    };

    initContent = ''
      # ls after cd (fish ls_after_cd)
      autoload -U add-zsh-hook
      function _ls_after_cd { ls -a; }
      add-zsh-hook chpwd _ls_after_cd

      # ctrl-p / ctrl-n prefix history search (fish up-or-search)
      bindkey '^P' history-substring-search-up
      bindkey '^N' history-substring-search-down
    '';
  };
}
