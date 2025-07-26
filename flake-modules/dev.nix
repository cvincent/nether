{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.dev.postgresql.enable = lib.mkEnableOption "Easier use of postgresql for dev";
      };

      config =
        { }
        // (lib.mkIf config.nether.dev.postgresql.enable {
          # Rails apps with multiple databases don't allow you to set the socket
          # location; and it's just convenient to not have to modify
          # postgresql.conf unix_socket_directories for each dev shell
          systemd.tmpfiles.rules = [
            "d /run/postgresql 0755 ${config.nether.username} users -"
          ];
        });
    };
}
