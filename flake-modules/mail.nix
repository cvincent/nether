{ name }:
{ lib, moduleWithSystem, ... }:
{
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
      };

      config = lib.mkIf config.nether.mail.enable {
        services.peroxide.enable = config.nether.mail.peroxide.enable;
      };
    };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, config, ... }:
    {
      config = lib.mkIf osConfig.nether.mail.enable (
        { }
        // lib.mkIf osConfig.nether.mail.davmail.enable (import ./mail/davmail.nix { inherit config pkgs; })
      );
    }
  );
}
