{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    let
      inherit (config.nether) dev;
    in
    {
      options = {
        nether.dev.beam.enable = lib.mkEnableOption "Configuration for an easier time in BEAM languages";
        nether.dev.postgresql.enable = lib.mkEnableOption "Easier use of postgresql for dev";
        nether.dev.ruby.enable = lib.mkEnableOption "Assistance in Ruby projects";
      };

      config = lib.mkMerge [
        { }
        (lib.mkIf dev.postgresql.enable {
          # Rails apps with multiple databases don't allow you to set the socket
          # location; and it's just convenient to not have to modify
          # postgresql.conf unix_socket_directories for each dev shell
          systemd.tmpfiles.rules = [
            "d /run/postgresql 0755 ${config.nether.username} users -"
          ];
        })
        (lib.mkIf dev.ruby.enable {
          nether.shells.aliases.be = "bundle exec ";
        })
      ];
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether) dev;
    in
    {
      config = lib.mkMerge [
        { }
        (lib.mkIf dev.beam.enable {
          home.sessionVariables.ERL_AFLAGS = "-kernel shell_history enabled";
        })
      ];
    };
}
