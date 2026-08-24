{ pkgs, ... }:

{
  imports = [ ../modules/tmux.nix ];
  programs.tmux.package = pkgs.tmux.overrideAttrs (old: {
    configureFlags = (old.configureFlags or [ ]) ++ [ "--disable-jemalloc" ];
  });
}
