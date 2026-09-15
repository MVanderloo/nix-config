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
            "delta"
            "theta"
          ];
        };

        documents = {
          label = "Documents";
          path = "${config.home.homeDirectory}/Documents";
          devices = [
            "delta"
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
