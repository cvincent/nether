{ name, mkSoftware, ... }:
mkSoftware name (
  { pkgs, ... }:
  {
    package = (
      pkgs.symlinkJoin {
        name = "FreeCAD";
        paths = [ pkgs.freecad-wayland ];
        buildInputs = [ pkgs.makeWrapper ];
        # TODO: This mesa, perhaps we need to pull it from the same input
        # Hyprland gets it from, which maybe means raising it up to a higher
        # option? Need to test.
        postBuild = ''
          wrapProgram $out/bin/FreeCAD \
          --set __GLX_VENDOR_LIBRARY_NAME mesa \
          --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
        '';
        meta.mainProgram = "FreeCAD";
      }
    );
  }
)
