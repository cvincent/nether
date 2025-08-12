{ name, mkFeature, ... }:
mkFeature name (
  { nether, ... }:
  {
    apps = {
      bambu-studio = { };

      freecad.nixos.nether.backups.paths."${nether.homeDirectory}/.config/FreeCAD".deleteMissing = true;
      libreoffice = { };
      nautilus.hm.dconf.settings."org/gnome/desktop/privacy".remember-recent-files = false;
      tigervnc.nixos.nether.backups.paths."${nether.homeDirectory}/.config/tigervnc".deleteMissing = true;

      transmission_4.hm.xdg.mimeApps.defaultApplications."x-scheme-handler/magnet" =
        "transmission_4.desktop";

      # TODO: Move these to a new gaming.nix feature, along with Steam
      ryujinx = { };
      shadps4 = { };

      zathura.hm.xdg.mimeApps.defaultApplications."application/pdf" = "org.pwmt.zathura-cb.desktop";
    };
  }
)
