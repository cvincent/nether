{ name }:
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
  # Flake of its own so others can easily use the functionality.
  flake.nixosModules."${name}" =
    { config, ... }:
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
      };
    };

  flake.homeModules."${name}" = moduleWithSystem (
    { self', pkgs }:
    {
      osConfig,
      config,
      utils,
      ...
    }:
    {
      config = lib.mkIf osConfig.nether.mail.enable (
        { }
        // lib.mkIf osConfig.nether.mail.misc.enable (
          (import ./mail/misc.nix {
            inherit
              config
              pkgs
              utils
              private-nethers
              ;
          })
          // (import ./mail/maildir-rank-addr.nix {
            inherit config pkgs;
            inherit (self'.packages) maildir-rank-addr;
          })
          // (import ./mail/notifications/email.nix { inherit config pkgs; })
          // (import ./mail/notifications/events.nix { inherit config pkgs; })
        )
        // lib.mkIf osConfig.nether.mail.davmail.enable (import ./mail/davmail.nix { inherit config pkgs; })
      );
    }
  );
}
