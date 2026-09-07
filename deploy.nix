{
  deploy-rs,
  homeConfigurations,
  nixosConfigurations,
}:

let
  activate = deploy-rs.lib.x86_64-linux.activate;
  tailnetDomain = "bongo-sidemirror.ts.net.";
in
{
  # deploy-rs invokes OpenSSH directly, so reproduce the transport and host-key
  # verification that the `tailscale ssh` wrapper normally supplies.
  sshOpts = [
    "-o"
    "ProxyCommand=tailscale nc %h %p"
    "-o"
    "StrictHostKeyChecking=yes"
    "-o"
    "UserKnownHostsFile=%d/.config/tailscale/ssh_known_hosts"
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
