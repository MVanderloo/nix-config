{ ... }:
{
  imports = [ ./neovim.nix ];

  home = {
    shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

}
