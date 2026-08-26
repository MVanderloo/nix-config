{ pkgs, ... }:
let
  user = "mi30175";
  proxy = "http://llproxy.llan.ll.mit.edu:8080";
  no_proxy = ".ll.mit.edu,.mit.edu,localhost,127.0.0.1";
in
{
  imports = [
    ../darwin/homebrew.nix
    ../darwin/nix-settings.nix
    ../darwin/settings.nix
  ];

  system = {
    stateVersion = 7;
    primaryUser = user;
  };

  # nix proxy settings
  nix.envVars = {
    ALL_PROXY = proxy;
    HTTPS_PROXY = proxy;
    HTTP_PROXY = proxy;
    NO_PROXY = no_proxy;
  };

  nixpkgs.config.allowUnfree = true;

  # system proxy settings
  environment.variables = {
    ALL_PROXY = proxy;
    HTTPS_PROXY = proxy;
    HTTP_PROXY = proxy;
    NO_PROXY = no_proxy;
  };

  # UID 350 and 351 already existed
  ids.uids.nixbld = 351;

  users.users.${user} = {
    home = "/Users/${user}";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
