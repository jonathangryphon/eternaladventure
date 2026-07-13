{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/common.nix
    ./disko.nix
  ];

  # ZFS requires a unique 8-hex-char hostId
  networking.hostId = "0e7543bb"; # generate fresh: head -c4 /dev/urandom | od -A none -t x4

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- initrd: network + dropbear for remote passphrase unlock ---
  boot.initrd.systemd.enable = true; # required for zfs unlock prompts to work cleanly w/ dropbear in this combo

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 62020;
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHawf4YO7tfG/BkWfw0E+aQRThKTIsGjXSwDBfQK/VGF charity@macbook"
      ];
      hostKeys = [
        "/etc/secrets/initrd/ssh_host_ed25519_key" # must persist across rebuilds — see note below
      ];
    };
    # DHCP is default on Hetzner private+public net; if static IP needed instead:
    # postCommands = "ip addr add <ip>/<cidr> dev eth0; ip link set eth0 up; ip route add default via <gateway>";
  };

  boot.initrd.availableKernelModules = [ "virtio_net" "virtio_scsi" "virtio_pci" "virtio_blk" ];

  # --- networking (regular, post-boot) ---
  networking.hostName = "dr-dryrun";
  networking.useDHCP = lib.mkDefault true;
  networking.firewall.allowedTCPPorts = [ 62020 ];

  mySsh.port = 62025; # per-host convention, pick unused port

  sops.secrets."initrd_ssh_host_key" = {
    sopsFile = ../../secrets/dr-dryrun-initrd-key.enc;
    format = "binary";
    path = "/etc/secrets/initrd/ssh_host_ed25519_key";
  };

  boot.initrd.secrets = {
    "/etc/secrets/initrd/ssh_host_ed25519_key" = config.sops.secrets."initrd_ssh_host_key".path;
  };

  # --- users ---
  # inherited from modules/users/ via common.nix — confirm it covers this host,
  # or add dry-run-specific user block here if common.nix expects per-host overrides

  system.stateVersion = "24.05"; # match whatever afabel/keep currently use
}