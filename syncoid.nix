{ config, pkgs, ... }:
{
    users.users.syncoid = {
        description = "user for zfs backups";
        shell = pkgs.bash;
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKSEdTI/abCPT3mzcewZlssKY8IgBqr4bkIIA/tU2SD syncoid@Lulu"
        ];
    };
}