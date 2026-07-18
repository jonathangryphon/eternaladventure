{ config, lib, ... }:
let inherit (lib) mkOption types;
in {
  options.myServer.restic = {
    repoPath = mkOption {
      type = types.str;
      default = "b2:eternal-adventure";
      description = "Restic repository path for this host (root for afabel, prefixed for others).";
    };
  };
  config = {
    sops.secrets."restic_repo_pw" = {};
    sops.secrets."b2backblaze" = {};

    services.restic.backups.b2 = {
      initialize = true;
      repository = config.myServer.restic.repoPath;
      passwordFile = config.sops.secrets."restic_repo_pw".path;
      environmentFile = config.sops.secrets."b2backblaze".path;
      paths = [ "/tank/services" "/etc/ssh" ];
      timerConfig = { OnCalendar = "daily"; Persistent = true; };
      pruneOpts = [ "--keep-daily 7" "--keep-weekly 4" "--keep-monthly 6" ];
    };

    sops.secrets."restic_repo_pw" = {
      sopsFile = ../secrets/restic_repo_pw;
      format = "binary";
    };  
    sops.secrets."b2backblaze" = {
      sopsFile = ../secrets/b2backblaze.env;
      format = "dotenv";
    };
  };
}
