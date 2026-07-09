{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };
    
  # Must use real vfat mount, NOT autofs/systemd-1
  # autofs causes boot files to be written to wrong place during rebuild
  # See: https://github.com/nvmd/nixos-raspberrypi/issues/120
  fileSystems."/boot/firmware" =
    { device = "/dev/disk/by-uuid/2175-794E";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
