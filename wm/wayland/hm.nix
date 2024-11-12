{ pkgs, lib, nixpkgs-unstable, ... }:

{
  imports = [
    ../essential/hm.nix
    ./swaylock/hm.nix
    ./swaync/hm.nix
    ./wallpapers/hm.nix
  ];

  home.packages = with pkgs; [
    # Clipboard
    wl-clipboard
    cliphist
    wl-clip-persist

    # Screenshots
    grim
    slurp
    swappy

    # Display management
    nwg-displays
    wlr-randr # required by nwg-displays

    swayidle
    waybar

    nixpkgs-unstable.xwaylandvideobridge
  ];

  programs.fuzzel = {
    enable = true;
    settings = {
      border.width = "5";
    };
  };

  services.avizo = {
    enable = true;
    settings = {
      default = {
        time = 0.5;
      };
    };
  };
}
