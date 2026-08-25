{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = false;
      extraEnv = {
        HOMEBREW_NO_ENV_HISTS = 1;
        HOMEBREW_NO_ANALYTICS = 1;
      };
    };
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
