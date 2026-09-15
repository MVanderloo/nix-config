{ config, ... }:

{
  services.syncthing = {
    enable = true;

    guiAddress = "127.0.0.1:8384";
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        tau = {
          id = "XNNZVDO-SH4PFVT-TMSNNAK-63H3LHU-OFVSEUV-DIXEQ4O-5MTJW6A-DHWUXAW";
          addresses = [ "tcp://tau:22000" ];
        };
        theta = {
          id = "7EMGCVJ-REVECEN-TCLPJYD-XWGQ6YN-RE2FUJA-7PVJU6U-NPSMLO7-NSKDNQY";
          addresses = [ "tcp://theta:22000" ];
        };
      };

      folders = {
        sync = {
          label = "Sync";
          path = "${config.home.homeDirectory}/Sync";
          devices = [
            "tau"
            "theta"
          ];
        };

        documents = {
          label = "Documents";
          path = "${config.home.homeDirectory}/Documents";
          devices = [
            "tau"
            "theta"
          ];
        };
      };

      options = {
        globalAnnounceEnabled = false;
        listenAddresses = [ "tcp://0.0.0.0:22000" ];
        localAnnounceEnabled = false;
        natEnabled = false;
        relaysEnabled = false;
        urAccepted = -1;
      };
    };
  };
}
