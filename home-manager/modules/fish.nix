{
  imports = [ ./shell.nix ];
  programs = {
    dircolors.enableFishIntegration = true;
    direnv.enableFishIntegration = true;
    fish = {
      enable = true;
      # TODO: cursor is not what I want
      interactiveShellInit = ''
        fish_vi_cursor
      '';
      functions = {
        fish_greeting = "";
        fish_user_keybindings = ''
          fish_default_key_bindings -M insert
          bind -M insert ctrl-p up-or-search
          bind -M insert ctrl-n down-or-search
        '';
        ls_after_cd = {
          onVariable = "PWD";
          body = "ls -a";
        };
      };
    };
    ghostty.enableFishIntegration = true;
    starship.enableFishIntegration = true;
    yazi.enableFishIntegration = true;
    zoxide.enableFishIntegration = true;
  };
}
