{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.dev.beam.enable = lib.mkEnableOption "Configuration for an easier time in BEAM languages";
        nether.dev.postgresql.enable = lib.mkEnableOption "Easier use of postgresql for dev";
      };

      config = lib.mkMerge [
        { }
        (lib.mkIf config.nether.dev.postgresql.enable {
          # Rails apps with multiple databases don't allow you to set the socket
          # location; and it's just convenient to not have to modify
          # postgresql.conf unix_socket_directories for each dev shell
          systemd.tmpfiles.rules = [
            "d /run/postgresql 0755 ${config.nether.username} users -"
          ];
        })
      ];
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      config = lib.mkMerge [
        { }
        (lib.mkIf osConfig.nether.dev.beam.enable {
          home.sessionVariables.ERL_AFLAGS = "-kernel shell_history enabled";
        })
      ];
    };
}
