{ pkgs, lib, myUsername, myHomeDir, ... }:

{
  # Don't change without reading release notes!
  home.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;

  home.username = myUsername;
  home.homeDirectory = myHomeDir;

  imports = [
    ./sops/hm.nix
    ./fonts/hm.nix
    ./stylix/hm.nix
    ./wm/hyprland/hm.nix

    ./services/xremap/hm.nix
    ./services/dconf

    ./apps/browsers
    ./apps/kitty
    ./apps/misc
    ./apps/mpv
    ./apps/nvim
    ./apps/slack
    ./apps/spotify
    ./apps/ytsub

    ./shell/fish
    ./shell/jira-cli
    ./shell/misc
    ./shell/tmux
  ];

  programs.home-manager.enable = true;
}
