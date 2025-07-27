{ name }:
{
  lib,
  moduleWithSystem,
  inputs,
  ...
}:
{
  # TODO: Break this out into smaller modules
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options.nether.miscApps.enable = lib.mkEnableOption "Grab-bag of miscellaneous desktop applications which I need to sort into smaller modules";

      config = lib.mkIf (config.nether.miscApps.enable && config.nether.flatpak.enable) {
        services.flatpak.packages = [ "app.bluebubbles.BlueBubbles" ];

        nether.backups.paths = {
          "${config.nether.homeDirectory}/.config/discord".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/discordcanary".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/Signal".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/Slack".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/spotify".deleteMissing = true;
          "${config.nether.homeDirectory}/.local/share/fractal".deleteMissing = true;
          "${config.nether.homeDirectory}/.var/app/app.bluebubbles.BlueBubbles".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/obsidian".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/FreeCAD".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/tigervnc".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/zoom.conf".deleteMissing = true;
          "${config.nether.homeDirectory}/.config/zoomus.conf".deleteMissing = true;
        };
      };
    };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs, pkgInputs }:
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.miscApps.enable {
        home.packages = with pkgs; [
          fractal
          showmethekey
          libreoffice
          nautilus
          bambu-studio
          discord-canary
          slack
          zoom-us
          signal-desktop
          spotify
          transmission_4-gtk
          pkgInputs.nixpkgs-unstable.ryujinx
          pkgInputs.nixpkgs-unstable.shadps4
          obsidian
          (pkgs.symlinkJoin {
            name = "FreeCAD";
            paths = [ pkgs.freecad-wayland ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/FreeCAD \
              --set __GLX_VENDOR_LIBRARY_NAME mesa \
              --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
            '';
            meta.mainProgram = "FreeCAD";
          })
        ];

        programs.zathura.enable = true;

        xdg.mimeApps = {
          defaultApplications."application/pdf" = "org.pwmt.zathura-cb.desktop";
          defaultApplications."x-scheme-handler/magnet" = "userapp-transmission-gtk-SLUX52.desktop";
        };

        dconf.settings = {
          "org/gnome/desktop/privacy" = {
            remember-recent-files = false;
          };
        };

        home.sessionVariables.OBSIDIAN_REST_API_KEY = inputs.private-nethers.obsidianRestAPIKey;
      };
    }
  );
}
