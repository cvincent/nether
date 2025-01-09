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

  latest-shadps4 = (
    nixpkgs-unstable.shadps4.overrideAttrs (
      final: prev: {
        src = nixpkgs-unstable.fetchFromGitHub {
          owner = "shadps4-emu";
          repo = "shadPS4";
          rev = "a1a98966eee07e7ecf3a5e3836b5f2ecde5664b0";
          hash = "sha256-lN+qXvf+rHlfZt7iT/De/tMvAQJpqLGOJxrv9z4tX5c=";
          fetchSubmodules = true;
        };
      }
    )
  );
in
{
  home.packages = with pkgs; [
    fractal
    showmethekey
    libreoffice
    nautilus
    bambu-studio
    nixpkgs-unstable.discord
    nixpkgs-slack.slack
    nixpkgs-zoom.zoom-us
    xwayland-spotify
    nixpkgs-unstable.ryujinx
    latest-shadps4
  ];

  programs.zathura.enable = true;

  dconf.settings = {
    "org/gnome/desktop/privacy" = {
      remember-recent-files = false;
    };
  };
}
