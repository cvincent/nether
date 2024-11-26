{
  pkgs,
  nixpkgs-slack,
  nixpkgs-unstable,
  nixpkgs-zoom,
  ...
}:

{
  home.packages = with pkgs; [
    fractal
    showmethekey
    libreoffice
    gnome.nautilus
    nixpkgs-unstable.discord
    nixpkgs-slack.slack
    nixpkgs-zoom.zoom-us
    nixpkgs-unstable.spotify
  ];

  programs.zathura.enable = true;

  dconf.settings = {
    "org/gnome/desktop/privacy" = {
      remember-recent-files = false;
    };
  };
}
