{ name, mkFeature, ... }:
mkFeature name (
  { nether, pkgInputs, ... }:
  {
    apps = {
      bambu-studio-flatpak.nixos.services.flatpak.packages = [
        {
          appId = "com.bambulab.BambuStudio";
          origin = "flathub";
        }
      ];

      bitwig-studio.package = pkgInputs.nixpkgs-bitwig-studio.bitwig-studio5;

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

      # NOTE: Useful on its own, but mainly installed as a dependency of
      # mpv-delete-current-file. We eventually want to replace that package with
      # a better script of our own. When we do, we should package it properly
      # with trash-cli as a dependency (though we will probably keep it here
      # too).
      trash-cli = { };

      # TODO: Move these to a new gaming.nix feature, along with Steam
      ryubing = { };
      shadps4 = { };

      wget = { };

      zathura.hm.xdg.mimeApps.defaultApplications."application/pdf" = "org.pwmt.zathura-cb.desktop";
    };
  }
)
