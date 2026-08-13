{ pkgs, ... }:
{
  imports = [
    ../darwin/settings.nix
  ];
  system = {
    stateVersion = 7;
    primaryUser = "mi30175";
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      use-xdg-base-directories = true;
    };
    envVars = {
      HTTP_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
      HTTPS_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
      ALL_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
      NO_PROXY = ".ll.mit.edu,.mit.edu,localhost,127.0.0.1";
    };
  };

  ids.uids.nixbld = 351;

  users.users.mi30175 = {
    home = "/Users/mi30175";
    shell = pkgs.fish;
  };

  environment.variables = {
    HTTPS_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    HTTP_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    ALL_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    NO_PROXY = ".ll.mit.edu,.mit.edu,localhost,127.0.0.1";
  };

  programs.fish.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    # brews = [ ];
    casks = [
      "keepassxc"
      "raycast"
    ];
  };
}
