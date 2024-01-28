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
    ./services/dconf/hm.nix

    ./apps/browsers/hm.nix
    ./apps/email/hm.nix
    ./apps/kitty/hm.nix
    ./apps/misc/hm.nix
    ./apps/mpv/hm.nix
    ./apps/nvim/hm.nix
    ./apps/slack/hm.nix
    ./apps/smartcalc-tui/hm.nix
    ./apps/spotify/hm.nix
    ./apps/ytsub/hm.nix

    ./shell/fish/hm.nix
    ./shell/jira-cli/hm.nix
    ./shell/misc/hm.nix
    ./shell/tmux/hm.nix
  ];

  programs.home-manager.enable = true;
}
