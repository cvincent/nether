{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.flatpak.enable = lib.mkEnableOption "Flatpak application packaging and distribution";
      };

      config = lib.mkIf config.nether.flatpak.enable {
        services.flatpak.enable = true;
        xdg.portal.enable = true;
        xdg.portal.config.common.default = lib.mkDefault "*";
      };
    };
}
