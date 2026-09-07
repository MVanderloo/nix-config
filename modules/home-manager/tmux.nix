{
  xdg.configFile."tmux/tmux.conf".source = ../../dotfiles/tmux.conf;

  programs = {
    sesh = {
      enable = true;
      enableAlias = false;
      enableTmuxIntegration = false;
    };
    tmux.enable = true;
  };
}
