{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    dev,
    lib,
    pkgs,
    ...
  }:
  {
    options = {
      # We could define these in toplevel, but I prefer them to have descriptions
      # since these options aren't actually for installing software.
      beam.enable = lib.mkEnableOption "Configuration for an easier time in BEAM languages";
      c.enable = lib.mkEnableOption "Easier C dev";
      postgresql.enable = lib.mkEnableOption "Easier use of postgresql for dev";
      ruby.enable = lib.mkEnableOption "Assistance in Ruby projects";
      shell.enable = lib.mkEnableOption "Assistance for shell scripting";
    };

    toplevel = {
      jujutsu = { };
      tldr = { };
    };

    nixos = lib.mkMerge [
      (lib.mkIf dev.c.enable {
        documentation = {
          dev.enable = true;
          doc.enable = true;
          man.generateCaches = true;
        };

        environment.systemPackages = with pkgs; [
          man-pages
          man-pages-posix
        ];
      })

      (lib.mkIf dev.postgresql.enable {
        systemd.tmpfiles.rules = [
          "d /run/postgresql 0755 ${nether.username} users -"
        ];
      })

      (lib.mkIf dev.ruby.enable {
        # TODO: This could maybe go in devShell
        nether.shells.aliases.be = "bundle exec ";
      })

      (lib.mkIf dev.shell.enable {
        environment.systemPackages = [ pkgs.shellcheck ];
      })
    ];

    hm = lib.mkMerge [
      (lib.mkIf dev.beam.enable {
        # TODO: This could maybe go in devShell
        home.sessionVariables.ERL_AFLAGS = "-kernel shell_history enabled";
      })

      (lib.mkIf dev.c.enable {
        programs.man.generateCaches = true;
      })
    ];
  }
)
