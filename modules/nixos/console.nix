{
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    useXkbConfig = true;
    earlySetup = true;
  };

  services.xserver.xkb.options = "ctrl:nocaps";
}
