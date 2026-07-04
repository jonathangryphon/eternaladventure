{ config, ... }:
{
  sops.secrets."restic_repo_pw" = {};
  sops.secrets."b2backblaze" = {};

  services.restic.backups.b2 = {
    initialize = true;
    repository = "b2:eternal-adventure";
    passwordFile = config.sops.secrets."restic_repo_pw".path;
    environmentFile = config.sops.secrets."b2backblaze".path;
    paths = [ "/tank/services" "/etc/ssh" ];
    timerConfig = { OnCalendar = "daily"; Persistent = true; };
    pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
  };
}
