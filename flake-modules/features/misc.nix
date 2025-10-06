{ name, mkFeature, ... }:
mkFeature name (
  { nether, ... }:
  {
    apps = {
      bambu-studio = { };

      exiftool = { };
      feh = { };
      freecad.nixos.nether.backups.paths."${nether.homeDirectory}/.config/FreeCAD".deleteMissing = true;
      libreoffice = { };
      nautilus.hm.dconf.settings."org/gnome/desktop/privacy".remember-recent-files = false;
      # TODO: Belongs in a new gaming.nix feature, this is Minecraft btw
      prismlauncher = { };
      tigervnc.nixos.nether.backups.paths."${nether.homeDirectory}/.config/tigervnc".deleteMissing = true;

      transmission_4-gtk.hm.xdg.mimeApps.defaultApplications."x-scheme-handler/magnet" =
        "userapp-transmission-gtk-VU41B3.desktop";

      # TODO: Move these to a new gaming.nix feature, along with Steam
      ryubing = { };
      shadps4 = { };

      wget = { };

      zathura.hm.xdg.mimeApps.defaultApplications."application/pdf" = "org.pwmt.zathura-cb.desktop";
    };
  }
)
