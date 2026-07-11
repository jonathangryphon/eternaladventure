{ config, lib, pkgs, ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = "github:jonathangryphon/eternaladventure#" + config.networking.hostName;
    flags = [ "--impure" ];   # only if this host needs it (keep does, afabel doesn't)
    dates = "Sun 03:00";
    randomizedDelaySec = "45min";
    allowReboot = false;   # never auto-reboot a headless box unattended — you confirm manually
  };

  # keep last few generations regardless, cheap rollback insurance
  boot.loader.grub.configurationLimit = lib.mkDefault 5;
  # (or systemd-boot.configurationLimit, whichever loader applies)
}