{ pkgs, ... }:

{
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

  # security.pam.services.sudo_local.text = ''
  # auth       sufficient     pam_u2f.so authfile=/etc/u2f_keys cue
  # '';

  ids.uids.nixbld = 351;

  system.stateVersion = 7;
  system.primaryUser = "mi30175";

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
