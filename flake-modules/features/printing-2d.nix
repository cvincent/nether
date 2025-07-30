{ name, ... }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    {
      options = {
        nether.printing2D.enable = lib.mkEnableOption "Printing in two dimensions";
      };

      config = lib.mkIf config.nether.printing2D.enable {
        services.printing.enable = true;

        hardware.printers = {
          ensurePrinters = [
            {
              name = "OfficeJet-4650";
              location = "Home";
              deviceUri = "hp:/net/OfficeJet_4650_series?ip=192.168.1.124";
              model = "drv:///sample.drv/generic.ppd";
              ppdOptions = {
                PageSize = "A4";
              };
            }
          ];
          ensureDefaultPrinter = "OfficeJet-4650";
        };

        services.printing.drivers = [ pkgs.hplip ];

        # Supports pretty much any "Apple compatible" printer, without drivers
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };

        # Scanning
        hardware.sane = {
          enable = true;
          extraBackends = [ pkgs.hplipWithPlugin ];
        };

        users.users."${config.nether.username}".extraGroups = [
          "scanner"
          "lp"
        ];
      };
    }
  );
}
