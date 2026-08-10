{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = "nix-command flakes";
    use-xdg-base-directories = true;
  };
  ids.uids.nixbld = 351;

  system = {
    stateVersion = 7;
    primaryUser = "mi30175";
  };

  environment.variables = {
    HTTPS_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    HTTP_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    ALL_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    NO_PROXY = ".ll.mit.edu,.mit.edu,localhost,127.0.0.1";
  };

  users.users.mi30175 = {
    home = "/Users/mi30175";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none";
    };
    casks = [
      "ghostty"
    ];
    # brews = [ ];   # formulae, if any
  };
}
