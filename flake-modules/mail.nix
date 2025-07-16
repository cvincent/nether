{ name }:
{ lib, ... }:
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
      };

      config = lib.mkIf config.nether.mail.enable {
        services.peroxide.enable = config.nether.mail.peroxide.enable;
      };
    };
}
