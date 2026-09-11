{
  description = "Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.disko.follows = "disko";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixos-stable.follows = "nixpkgs-stable";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    # waylandcraft-desktop.url = "path:/home/mv/waylandcraft-desktop";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      darwin,
      deploy-rs,
      quadlet-nix,
      ...
    }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      forAllSystems = nixpkgs.lib.genAttrs [
        linuxSystem
        darwinSystem
      ];

      secrets = {
        adminPassword = ./secrets/admin-password.yaml;
        alphaPocketId = ./secrets/alpha-pocket-id.yaml;
        thetaHermes = ./secrets/theta-hermes.yaml;
        thetaTrmnl = ./secrets/theta-trmnl.yaml;
      };

      commonArgs = {
        inherit inputs;
      };

      localOverlay = import ./packages {
        inherit (inputs) neovim-nightly;
      };
      overlayModule = {
        nixpkgs.overlays = [ localOverlay ];
      };
      linuxPkgs = nixpkgs.legacyPackages.${linuxSystem}.extend localOverlay;
      darwinPkgs = nixpkgs.legacyPackages.${darwinSystem}.extend localOverlay;

      # Upstream deliberately disables SSH host-key checking by default.  That
      # is unsafe when --extra-files contains tau's persistent SOPS key.  Keep
      # its temporary client-identity behavior, but require callers to pass an
      # explicitly pinned known_hosts file and ignore ambient SSH config. Also
      # stop ssh-copy-id from broadening the first login to every agent key;
      # the guarded controller supplies one exact public IdentityFile.
      secureNixosAnywhere =
        system:
        inputs.nixos-anywhere.packages.${system}.default.overrideAttrs (old: {
          installPhase = old.installPhase + ''
            substituteInPlace "$out/libexec/nixos-anywhere/nixos-anywhere.sh" \
              --replace-fail \
                'declare -a sshArgs=("-o" "IdentitiesOnly=yes" "-i" "$tempDir/nixos-anywhere" "-o" "UserKnownHostsFile=/dev/null" "-o" "StrictHostKeyChecking=no")' \
                'declare -a sshArgs=("-F" "/dev/null" "-o" "IdentitiesOnly=yes" "-i" "$tempDir/nixos-anywhere")'
            substituteInPlace "$out/libexec/nixos-anywhere/nixos-anywhere.sh" \
              --replace-fail \
                '-o IdentitiesOnly=no' \
                '-o IdentitiesOnly=yes'
          '';
        });

      mkNixos =
        module:
        nixpkgs.lib.nixosSystem {
          system = linuxSystem;
          specialArgs = commonArgs // {
            inherit secrets;
          };
          modules = [
            overlayModule
            module
            quadlet-nix.nixosModules.quadlet
          ];
        };

      mkDarwin =
        module:
        darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = commonArgs;
          modules = [
            overlayModule
            module
          ];
        };

      mkHome =
        module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = linuxPkgs;
          extraSpecialArgs = commonArgs;
          modules = [ module ];
        };

      nixosImages = inputs.nixos-anywhere.inputs.nixos-images;
      kexecSystem = (
        nixpkgs.lib.nixosSystem {
          system = linuxSystem;
          modules = [
            nixosImages.nixosModules.kexec-installer
            nixosImages.nixosModules.noninteractive
            (
              { lib, pkgs, ... }:
              {
                # Tau uses Btrfs on LVM. Omitting the generic installer's
                # ZFS module avoids an unrelated source build on new nixpkgs.
                disabledModules = [ "${nixosImages.outPath}/nix/zfs-minimal.nix" ];

                system.kexec-installer.name = "nixos-kexec-installer";

                boot = {
                  kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
                  supportedFilesystems.bcachefs = lib.mkForce false;

                  initrd.availableKernelModules = [
                    "mii"
                    "r8152"
                    "usbnet"
                  ];
                  kernelModules = [ "r8152" ];

                  kernelParams = lib.mkAfter [ "console=tty0" ];
                };

                # The RAM-only installer does not need the newer-kernel /etc
                # overlay used by the generic netboot profile.
                system.etc.overlay.enable = lib.mkForce false;

                hardware.firmware = [
                  (pkgs.runCommand "rtl815x-firmware" { } ''
                    install -d "$out/lib/firmware/rtl_nic"
                    cp ${pkgs.linux-firmware}/lib/firmware/rtl_nic/rtl815*.fw \
                      "$out/lib/firmware/rtl_nic/"
                  '')
                ];
              }
            )
          ];
        }
      );

      # The upstream minimal image intentionally shrinks its kernel-module and
      # firmware set. Reuse its architecture-independent static launch helpers,
      # but replace its kernel, initrd, and run script with our configured ones.
      # This avoids rebuilding static iproute2 merely to add an Ethernet driver.
      stockKexecInstaller = linuxPkgs.fetchurl {
        url = "https://github.com/nix-community/nixos-images/releases/download/nixos-25.11/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz";
        hash = "sha256-ZAIMdbAhouP3JBjR8b+pdfzTkfV97jirOu9jmZHtyGA=";
      };
      kexecInstaller = linuxPkgs.runCommand "nixos-kexec-installer" { } ''
        install -d kexec "$out"
        tar -xzf ${stockKexecInstaller} --strip-components=1 \
          -C kexec kexec/ip kexec/kexec
        install -m 0644 \
          ${kexecSystem.config.system.build.netbootRamdisk}/initrd \
          kexec/initrd
        install -m 0644 \
          ${kexecSystem.config.system.build.kernel}/${kexecSystem.config.system.boot.loader.kernelFile} \
          kexec/bzImage
        install -m 0755 ${kexecSystem.config.system.build.kexecRun} kexec/run
        tar --sort=name --mtime=@1 --owner=0 --group=0 --numeric-owner \
          -czf "$out/nixos-kexec-installer-x86_64-linux.tar.gz" kexec
      '';
    in
    {
      overlays.default = localOverlay;

      apps = forAllSystems (system: {
        deploy = deploy-rs.apps.${system}.default // {
          meta.description = "Deploy this flake with deploy-rs";
        };
      });

      packages.${linuxSystem} = {
        inherit (linuxPkgs)
          neovim-head
          rayfish
          sops
          ;
        kexec-installer = kexecInstaller;
        nixos-anywhere = secureNixosAnywhere linuxSystem;
      };
      packages.${darwinSystem} = {
        inherit (darwinPkgs)
          neovim-head
          nixos-anywhere-reinstall
          sops
          ;
        nixos-anywhere = secureNixosAnywhere darwinSystem;
      };

      nixosConfigurations = {
        alpha = mkNixos ./hosts/alpha;
        tau = mkNixos ./hosts/tau;
        theta = mkNixos ./hosts/theta;
      };

      darwinConfigurations = {
        work-mac = mkDarwin ./hosts/work-mac;
      };

      homeConfigurations."mv@delta" = mkHome ./hosts/delta;

      deploy = import ./deploy.nix {
        inherit deploy-rs;
        inherit (self) homeConfigurations nixosConfigurations;
      };

      checks.${linuxSystem} = deploy-rs.lib.${linuxSystem}.deployChecks self.deploy;
      checks.${darwinSystem}.nixos-anywhere-reinstall = darwinPkgs.nixos-anywhere-reinstall.tests.unit;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
