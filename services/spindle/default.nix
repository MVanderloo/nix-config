{ lib, inputs, ... }:
{
  imports = [ inputs.tangled.nixosModules.spindle ];

  config = {
    services.tangled.spindle = {
      enable = true;
      server = {
        hostname = "spindle.mvanderloo.com";
        owner = "";
        maxJobCount = 2;
        queueSize = 100;
      };

      pipelines = {
        nixery.nixery = "nixery.tangled.sh";
        microvm.enableKVM = false;
      };
    };

    virtualisation.podman.dockerCompat = lib.mkDefault true;
  };
}
