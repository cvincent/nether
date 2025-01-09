{
  pkgs,
  nixpkgs-slack,
  nixpkgs-unstable,
  nixpkgs-zoom,
  ...
}:

let
  xwayland-spotify = (
    nixpkgs-unstable.spotify.overrideAttrs (
      final: prev: {
        postInstall = ''
          sed -i "s:^Exec=.*:Exec=env --unset NIXOS_OZONE_WL spotify %U:" "$out/share/applications/spotify.desktop"
        '';
      }
    )
  );
in
{
  home.packages = with pkgs; [
    fractal
    showmethekey
    libreoffice
    gnome.nautilus
    nixpkgs-unstable.discord
    nixpkgs-slack.slack
    nixpkgs-zoom.zoom-us
    xwayland-spotify
  ];

  programs.zathura.enable = true;

  dconf.settings = {
    "org/gnome/desktop/privacy" = {
      remember-recent-files = false;
    };
  };
}
