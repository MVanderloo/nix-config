{ pkgs, ... }:
{
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    useXkbConfig = true;
    earlySetup = true;
    packages = [ pkgs.terminus_font ];
    font = "ter-v24n";
  };

  services.xserver.xkb.options = "ctrl:nocaps";
}
