{
  programs.helium = {
    enable = true;
    policies.ExtensionInstallForcelist = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
      "hfjbmagddngcpeloejdejnfgbamkjaeg" # Vimium C
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
    ];
  };
}
