{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # This should go under networking.nix and enabled only when
    # nether.graphicalEnv.enable == true
    networkmanagerapplet
    # Probably generic graphicalEnv
    libnotify
    # These are audio.nix obv, with a graphicalEnv check
    pavucontrol
    playerctl
    alsa-utils
  ];

  # Probably media.nix
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.wlrobs ];
  };
}
