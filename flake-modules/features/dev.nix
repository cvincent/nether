{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    dev,
    lib,
    ...
  }:
  {
    options = {
      beam.enable = lib.mkEnableOption "Configuration for an easier time in BEAM languages";
      postgresql.enable = lib.mkEnableOption "Easier use of postgresql for dev";
      ruby.enable = lib.mkEnableOption "Assistance in Ruby projects";
    };

    nixos =
      { }
      |> lib.recursiveUpdate (
        lib.mkIf dev.postgresql.enable {
          systemd.tmpfiles.rules = [
            "d /run/postgresql 0755 ${nether.username} users -"
          ];
        }
      )
      |> lib.recursiveUpdate (
        lib.mkIf dev.ruby.enable {
          # TODO: This could maybe go in devShell
          nether.shells.aliases.be = "bundle exec ";
        }
      );

    hm =
      { }
      |> lib.recursiveUpdate (
        lib.mkIf dev.beam.enable {
          # TODO: This could maybe go in devShell
          home.sessionVariables.ERL_AFLAGS = "-kernel shell_history enabled";
        }
      );
  }
)
