{
  deploy-rs,
  homeConfigurations,
  nixosConfigurations,
}:

let
  activate = deploy-rs.lib.x86_64-linux.activate;
in
{
  nodes = {
    alpha = {
      hostname = "alpha";
      sshUser = "mv";
      interactiveSudo = true;
      remoteBuild = false;

      profiles.system = {
        user = "root";
        path = activate.nixos nixosConfigurations.alpha;
      };
    };

    delta = {
      hostname = "delta";
      sshUser = "mv";
      remoteBuild = true;

      profiles.system = {
        user = "mv";
        path = activate.home-manager homeConfigurations."mv@delta";
      };
    };

    theta = {
      hostname = "theta";
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
