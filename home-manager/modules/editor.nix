{ inputs, pkgs, ... }:
{
  home = {
    packages = [
      inputs.neovim-config.packages.${pkgs.system}.default
    ];

    shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = {
    # neovim = {
    #   enable = true;
    #   defaultEditor = true;
    #   vimAlias = true;
    #   vimdiffAlias = true;
    #   sideloadInitLua = true;
    # };
  };
}
