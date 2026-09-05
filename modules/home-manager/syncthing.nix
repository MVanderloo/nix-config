{
  config,
  lib,
  ...
}:

let
  devices = {
    delta = {
      id = "HODCZPB-SDZ5Q4J-NDKTLZ2-DFZWDRZ-U2NXO6A-N2JU5KR-6EZ6GF2-UZ6RQQZ";
      addresses = [ "tcp://delta:22000" ];
    };
    tau = {
      id = "XNNZVDO-SH4PFVT-TMSNNAK-63H3LHU-OFVSEUV-DIXEQ4O-5MTJW6A-DHWUXAW";
      addresses = [ "tcp://tau:22000" ];
    };
    theta = {
      id = "7EMGCVJ-REVECEN-TCLPJYD-XWGQ6YN-RE2FUJA-7PVJU6U-NPSMLO7-NSKDNQY";
      addresses = [ "tcp://theta:22000" ];
    };
  };

  deviceName = config.services.syncthing.deviceName;
  isSyncDevice = deviceName != null;
  remoteDevices = lib.removeAttrs devices (lib.optional isSyncDevice deviceName);
  remoteDeviceNames = builtins.attrNames remoteDevices;
in
{
  options.services.syncthing.deviceName = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum (builtins.attrNames devices));
    default = null;
    description = "Name of this device in the shared Syncthing configuration.";
  };

  config.services.syncthing = {
    enable = true;

    guiAddress = "127.0.0.1:8384";
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = lib.optionalAttrs isSyncDevice remoteDevices;

      folders = lib.optionalAttrs isSyncDevice {
        sync = {
          label = "Sync";
          path = "${config.home.homeDirectory}/Sync";
          devices = remoteDeviceNames;
        };

        documents = {
          label = "Documents";
          path = "${config.home.homeDirectory}/Documents";
          devices = remoteDeviceNames;
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
