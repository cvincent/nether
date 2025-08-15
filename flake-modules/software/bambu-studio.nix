{ name, mkSoftware, ... }:
mkSoftware name (
  { bambu-studio, ... }:
  {
    # nixos.services.flatpak = {
    #   packages = [ "com.bambulab.BambuStudio" ];
    # };
    hm.home.packages = [ bambu-studio.package ];
  }
)
