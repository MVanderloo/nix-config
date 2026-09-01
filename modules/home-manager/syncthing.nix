{
  services.syncthing = {
    enable = true;

    guiAddress = "127.0.0.1:8384";
    overrideDevices = true;
    overrideFolders = true;

    settings.options = {
      globalAnnounceEnabled = false;
      listenAddresses = [ "tcp://0.0.0.0:22000" ];
      localAnnounceEnabled = false;
      natEnabled = false;
      relaysEnabled = false;
      urAccepted = -1;
    };
  };
}
