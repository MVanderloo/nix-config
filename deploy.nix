{
  deploy-rs,
  homeConfigurations,
  nixosConfigurations,
}:

let
  activate = deploy-rs.lib.x86_64-linux.activate;
  tailnetDomain = "bongo-sidemirror.ts.net.";
  deploySshConfig = builtins.toFile "deploy-ssh.conf" ''
    Host *.${tailnetDomain}
      ProxyCommand tailscale nc %h %p
      StrictHostKeyChecking yes
      UserKnownHostsFile %d/.config/tailscale/ssh_known_hosts
  '';
in
{
  # Keep the spaced ProxyCommand in a config file: deploy-rs flattens sshOpts
  # when passing them to remote Nix builds through NIX_SSHOPTS.
  sshOpts = [
    "-F"
    "${deploySshConfig}"
  ];

  nodes = {
    alpha = {
      hostname = "alpha.${tailnetDomain}";
      sshUser = "mv";
      interactiveSudo = true;
      remoteBuild = false;

      profiles.system = {
        user = "root";
        path = activate.nixos nixosConfigurations.alpha;
      };
    };

    delta = {
      hostname = "delta.${tailnetDomain}";
      sshUser = "mv";
      remoteBuild = true;

      profiles.system = {
        user = "mv";
        path = activate.home-manager homeConfigurations."mv@delta";
      };
    };

    theta = {
      hostname = "theta.${tailnetDomain}";
      sshUser = "mv";
      interactiveSudo = true;
      remoteBuild = true;

      profiles.system = {
        user = "root";
        path = activate.nixos nixosConfigurations.theta;
      };
    };
  };
}
