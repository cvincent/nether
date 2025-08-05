{ name, mkFeature, ... }:
mkFeature name (
  { lib, flatpak, ... }:
  {
    description = "Flatpak application packaging and distribution";

    nixos = {
      services.flatpak.enable = true;
      xdg.portal.enable = true;
      xdg.portal.config.common.default = lib.mkDefault "*";
    };
  }
)
