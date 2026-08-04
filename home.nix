{ pkgs, ... }:

{
  home = {
    stateVersion = "26.05";

    username = "mi30175";
    homeDirectory = /Users/mi30175;

    packages = with pkgs; [
      atuin
      bat
      btop
      cloc
      curl
      direnv
      duckdb
      dust
      eza
      fastfetch
      fd
      fzf
      gawk
      gh
      glab
      gnugrep
      jq
      just
      less
      man
      nixd
      nixfmt
      statix
      deadnix
      neovim
      openssh
      sd
      sesh
      sl
      starship
      tealdeer
      tmux
      unzip
      watchexec
      wget
      zoxide
    ];
  };

  programs.fish = {
    enable = true;

    shellInit = ''
      fish_add_path --move /run/current-system/sw/bin
      fish_add_path --move /nix/var/nix/profiles/default/bin
    '';
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
