{ pkgs, lib, ... }:

{
  imports = [
    ../essential
    ./swaylock/hm.nix
    ./swaync
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
  ];

  programs.fuzzel = {
    enable = true;
    settings = {
      colors.background = lib.mkForce "2e3440EE";
      border.width = "5";
    };
  };

  services.avizo.enable = true;
}
