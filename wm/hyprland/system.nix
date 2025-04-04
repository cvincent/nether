{ pkgs, inputs, ... }:

{
  imports = [ ../wayland/system.nix ];

  # Ensure the /tmp/hypr symlink exists to continue using older versions of
  # Waybar and Pyprland that don't require me to fix their configs, until I'm
  # ready and/or replace Waybar with Astal or something
  environment.systemPackages = [
    (pkgs.runCommand "tmp-hypr-symlink" { } ''
      ln -s /run/user/1000/hypr /tmp/hypr
      mkdir $out
    '')
  ];

  # Seems to me I'm always rebuilding binaries, maybe due to pinning the
  # Hyprland version in my flake. Either way, declaring this doesn't hurt
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  environment.sessionVariables = {
    # Recommended env vars from the Hyprland wiki
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # This is no longer a hard requirement in latest Hyprland or probably
    # Wayland more generally (fix was pulled from a wlroots patch), but I tried
    # without it and found the cursor quite stuttery still, including with
    # `allow_dumb_copy` in the Hyprland config
    WLR_NO_HARDWARE_CURSORS = "1";
    # This may help with laggy cursor? It's still laggy though
    OGL_DEDICATED_HW_STATE_PER_CONTEXT = "ENABLE_ROBUST";
    # Launch apps in native Wayland (not XWayland) by default
    NIXOS_OZONE_WL = "1";
    # Would be required for tearing, which we don't really need as we don't
    # game on here these days
    # WLR_DRM_NO_ATOMIC = "1";

    # Remove if Firefox crashes:
    GBM_BACKEND = "nvidia-drm";
    # Remove if issues with Discord windows or Zoom screensharing:
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # These would theoretically always offload, but offloading does not seem to
    # do shit for e.g. Chromium:
    # __NV_PRIME_RENDER_OFFLOAD = "1";
    # __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    # __VK_LAYER_NV_optimus = "NVIDIA_only";

    AQ_DRM_DEVICES = "/dev/dri/card1";
  };

  hardware.opengl = {
    package =
      inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa.drivers;
    package32 =
      inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pkgsi686Linux.mesa.drivers;
  };
}
