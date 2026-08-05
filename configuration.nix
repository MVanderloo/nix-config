{ pkgs, ... }:

{
  nix.settings.experimental-features = "nix-command flakes";
  nix.envVars = {
    HTTP_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    HTTPS_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    ALL_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    NO_PROXY = ".ll.mit.edu,.mit.edu,localhost,127.0.0.1";
  };

  ids.uids.nixbld = 351;

  system.stateVersion = 7;
  system.primaryUser = "mi30175";

  homebrew.enable = true;

  users.users.mi30175 = {
    home = "/Users/mi30175";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
