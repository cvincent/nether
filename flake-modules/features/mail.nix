{ name, ... }:
{
  lib,
  moduleWithSystem,
  inputs,
  ...
}:
let
  private-nethers = inputs.private-nethers;
in
{
  # TODO: Yes, our whole mail/calendar/contacts setup needs a lot of work. This
  # is one of the first significant chunks of Nix I ever wrote ported into our
  # much-improved Flake. Some of this could potentially be split off into a
  # Flake of its own so others can easily use the functionality. For now we're
  # leaving it be. An attempt was made at porting it to mkFeature, but it was
  # going to need a lot of rework due to the way things are imported. It's fine.
  # I think this module deserves basically a full rewrite, but it can limp along
  # as-is until we have the time.

  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgInputs }:
    { pkgs, config, ... }:
    {
      options = {
        nether.mail.enable = lib.mkEnableOption "Fetching, reading, and sending email";

        nether.mail.peroxide.enable = lib.mkOption {
          type = lib.types.bool;
          description = "Peroxide third-party bridge for ProtonMail";
          default = config.nether.mail.enable;
        };

        nether.mail.davmail.enable = lib.mkOption {
          type = lib.types.bool;
          description = "Davmail POP/IMAP/SMTP-Exchange gateway";
          default = config.nether.mail.enable;
        };

        nether.mail.misc.enable = lib.mkOption {
          type = lib.types.bool;
          description = "The rest of my mail/calendar/contacts setup, which I need to break into better modules";
          default = config.nether.mail.enable;
        };
      };

      config = lib.mkIf config.nether.mail.enable {
        services.peroxide.enable = config.nether.mail.peroxide.enable;
        services.peroxide.package = pkgInputs.nixpkgs-peroxide.peroxide;
        systemd.services.peroxide.serviceConfig.User = lib.mkForce config.nether.username;
        # TODO: We would probably prefer to run this as a user service. See also
        # notes on davmail.service.
        # TODO: We've switched these to graphical.target until we're ready to
        # bring restore-backups.service back. The thinking was, we don't want to
        # start syncing on a new install until we've first restored our mail
        # directory, so we don't have to resync everything from scratch.
        systemd.services.peroxide.requires = [ "graphical.target" ];
        systemd.services.peroxide.after = [ "graphical.target" ];
        services.logrotate.settings.peroxide.su = lib.mkForce "${config.nether.username} users";

        nether.backups.paths = lib.mkIf config.nether.mail.peroxide.enable {
          "/var/lib/peroxide/credentials.json" = { };
          "/var/lib/peroxide/cookies.json" = { };
          # TODO: Once all of this is in proper Flake modules, this should obviously
          # be grouped with the davmail configs
          "${config.nether.homeDirectory}/.davmail-token.properties" = { };
          "${config.nether.homeDirectory}/mail".deleteMissing = true;
          "${config.nether.homeDirectory}/.local/state/isync".deleteMissing = true;
          "${config.nether.homeDirectory}/.local/share/vdirsyncer".deleteMissing = true;
          "${config.nether.homeDirectory}/.local/state/vdirsyncer".deleteMissing = true;
        };

        system.activationScripts = lib.mkIf config.nether.mail.peroxide.enable {
          peroxide =
            let
              certPem = pkgs.writeText "peroxide-cert.pem" private-nethers.mail.peroxide.certPem;
              keyPem = pkgs.writeText "peroxide-key.pem" private-nethers.mail.peroxide.keyPem;
            in
            ''
              if [[ ! -d /var/lib/peroxide ]]; then
                mkdir -p /var/lib/peroxide
                ln -s ${certPem} /var/lib/peroxide/cert.pem
                ln -s ${keyPem} /var/lib/peroxide/key.pem
                chown -R ${config.nether.username}:users /var/lib/peroxide
              fi
            '';
        };
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      imports = lib.optionals osConfig.nether.mail.enable (
        [
          ./mail/notifications/email.nix
          ./mail/notifications/events.nix
        ]
        ++ lib.optional osConfig.nether.mail.misc.enable (
          import ./mail/misc.nix { inherit private-nethers; }
        )
        ++ lib.optional osConfig.nether.mail.misc.enable (
          moduleWithSystem (import ./mail/maildir-rank-addr.nix)
        )
        ++ lib.optional osConfig.nether.mail.davmail.enable ./mail/davmail.nix
      );
    };
}
