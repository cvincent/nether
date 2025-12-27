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
    { }:
    { pkgs, config, ... }:
    {
      options = {
        nether.mail.enable = lib.mkEnableOption "Fetching, reading, and sending email";

        nether.mail.hydroxide = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Third-party, open-source ProtonMail bridge";
            default = config.nether.mail.enable;
          };

          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.hydroxide;
          };
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
        environment.systemPackages = lib.mkIf config.nether.mail.hydroxide.enable [
          config.nether.mail.hydroxide.package
        ];

        nether.backups.paths = lib.mkIf config.nether.mail.enable {
          "${config.nether.homeDirectory}/.config/hydroxide/auth.json" = { };
          # TODO: Once all of this is in proper Flake modules, this should obviously
          # be grouped with the davmail configs
          "${config.nether.homeDirectory}/.davmail-token.properties" = { };
          "${config.nether.homeDirectory}/mail".deleteMissing = true;
          "${config.nether.homeDirectory}/.local/state/isync".deleteMissing = true;
          "${config.nether.homeDirectory}/.local/share/vdirsyncer".deleteMissing = true;
          "${config.nether.homeDirectory}/.local/state/vdirsyncer".deleteMissing = true;
        };
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      systemd.user.services.hydroxide = lib.mkIf osConfig.nether.mail.hydroxide.enable (
        let
          package = osConfig.nether.mail.hydroxide.package;
        in
        {
          Install.WantedBy = [ "graphical-session.target" ];
          Unit.After = [ "graphical-session.target" ];
          Service = {
            Type = "exec";
            ExecStart = "${package}/bin/hydroxide serve";
            Restart = "on-failure";
          };
        }
      );

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
