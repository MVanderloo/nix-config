{ pkgs, ... }:

{
  home.stateVersion = "26.05";

  home.username = "mi30175";
  home.homeDirectory = "/Users/mi30175";

  home.packages = with pkgs; [
    neovim
    tmux
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
    openssh
    sd
    sesh
    sl
    starship
    tealdeer
    unzip
    watchexec
    wget
    zoxide
  ];

  programs.fish = {
    enable = true;

    shellInit = ''
      fish_add_path --move /run/current-system/sw/bin
      fish_add_path --move /nix/var/nix/profiles/default/bin
    '';
  };
}
