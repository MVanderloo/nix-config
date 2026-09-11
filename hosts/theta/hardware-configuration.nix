{
  inputs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];

    # Mask malfunctioning AHCI port 4 (ata5), which adds
    # about 45 seconds of IDENTIFY timeouts to boot.
    kernelParams = [ "ahci.mask_port_map=0x2f" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
