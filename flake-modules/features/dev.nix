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
      beam.enable = lib.mkEnableOption "Configuration for an easier time in BEAM languages";
      c.enable = lib.mkEnableOption "Easier C dev";
      postgresql.enable = lib.mkEnableOption "Easier use of postgresql for dev";
      ruby.enable = lib.mkEnableOption "Assistance in Ruby projects";
    };

    toplevel = {
      jujutsu.hm.programs.jujutsu.enable = true;
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
