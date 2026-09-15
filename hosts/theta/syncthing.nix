{ config, ... }:

{
  services.syncthing = {
    enable = true;

    guiAddress = "127.0.0.1:8384";
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        delta = {
          id = "HODCZPB-SDZ5Q4J-NDKTLZ2-DFZWDRZ-U2NXO6A-N2JU5KR-6EZ6GF2-UZ6RQQZ";
          addresses = [ "tcp://delta:22000" ];
        };
        tau = {
          id = "XNNZVDO-SH4PFVT-TMSNNAK-63H3LHU-OFVSEUV-DIXEQ4O-5MTJW6A-DHWUXAW";
          addresses = [ "tcp://tau:22000" ];
        };
      };

      folders = {
        sync = {
          label = "Sync";
          path = "${config.home.homeDirectory}/Sync";
          devices = [
            "delta"
            "tau"
          ];
        };

        documents = {
          label = "Documents";
          path = "${config.home.homeDirectory}/Documents";
          devices = [
            "delta"
            "tau"
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
