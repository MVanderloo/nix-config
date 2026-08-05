{ pkgs, ... }:

{
  nix.settings.experimental-features = "nix-command flakes";
  nix.envVars = {
    HTTP_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    HTTPS_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    ALL_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    NO_PROXY = ".ll.mit.edu,.mit.edu,localhost,127.0.0.1";
    NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
  };

  ids.uids.nixbld = 351;

  system.stateVersion = 7;
  # system.primaryUser = "mi30175";

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.mi30175 = {
    home = "/Users/mi30175";
    shell = pkgs.fish;
  };

   programs.fish.enable = true;
  # homebrew.enable = true;
}
