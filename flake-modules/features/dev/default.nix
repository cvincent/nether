{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    dev,
    pkgs,
    helpers,
    pkgInputs,
    ...
  }:
  {
    toplevel = {
      delta = { };

      jj-fzf = { };

      jujutsu.package = pkgInputs.nixpkgs-jujutsu.jujutsu;

      tldr = { };
    };

    beam = {
      hm.home.sessionVariables.ERL_AFLAGS = "-kernel shell_history enabled";
    };

    c = {
      nixos = {
        documentation = {
          dev.enable = true;
          doc.enable = true;
          man.generateCaches = true;
        };

        environment.systemPackages = with pkgs; [
          man-pages
          man-pages-posix
        ];
      };

      hm.programs.man.generateCaches = true;
    };

    elixir = {
      hm.programs.tmux.extraConfig = ''
        bind-key -n C-d if-shell \
          "ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE 'beam.smp'" \
          "send-keys C-c" \
          "send-keys C-d"

        bind-key -n C-c if-shell \
          "ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE 'beam.smp'" \
          "send-keys '#iex:break' ENTER" \
          "send-keys C-c"
      '';
    };

    javascript = {
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

    postgresql = {
      nixos = {
        systemd.tmpfiles.rules = [
          "d /run/postgresql 0755 ${nether.username} users -"
        ];
      };
    };

    ruby = {
      nixos.nether.shells.aliases.be = "bundle exec ";
    };

    shell = {
      shellcheck = { };
      shfmt = { };
    };
  }
)
