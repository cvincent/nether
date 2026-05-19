{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    dev,
    lib,
    pkgs,
    helpers,
    pkgInputs,
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
      jujutsu = {
        package = pkgInputs.nixpkgs-jujutsu.jujutsu;
      };
      jj-fzf = { };
      tldr = { };

      javascript = {
        package = null;

        hm =
          let
            oneWeek = 60 * 60 * 24 * 7;
            npmrc = builtins.concatStringsSep "\n" [
              "minimum-release-age=${toString oneWeek}"
              "ignore-scripts=true"
            ];
          in
          {
            home.file.".npmrc".text = npmrc;

            xdg.configFile = {
              "pnpm/rc".text = npmrc;
              "pnpm/config.yaml".text = "minimumReleaseAge: ${toString oneWeek}";

              ".bunfig.toml".source = (pkgs.formats.toml { }).generate ".bunfig.toml" {
                install = {
                  ignoreScripts = true;
                  minimumReleaseAge = oneWeek;
                };
              };
            };
          };
      };

      nix = {
        package = null;

        options.scripts = builtins.listToAttrs (
          let
            nixRunReplaceVars = {
              inherit (nether) dotfilesDirectory;
              inherit (nether.networking) hostname;
            };
          in
          [
            (helpers.mkScript ./. "nix-run-script" {
              runtimeInputs = [ pkgs.nix ];
              replaceVars = nixRunReplaceVars;
            })

            (helpers.mkScript ./. "nix-run-script-with-dbus" {
              runtimeInputs = [ pkgs.nix ];
              replaceVars = nixRunReplaceVars;
            })
          ]
        );

        hm.home.packages = builtins.attrValues dev.nix.scripts;
      };
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

      {
        home.packages =
          [ ]
          ++ lib.optionals dev.shell.enable (
            with pkgs;
            [
              shellcheck
              shfmt
            ]
          );
      }
    ];
  }
)
