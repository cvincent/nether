{ pkgs, lib, myUsername, myHomeDir, ... }:

{
  # Don't change without reading release notes!
  home.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  # nixpkgs-latest.config.allowUnfree = true;

  home.username = myUsername;
  home.homeDirectory = myHomeDir;

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  imports = [
    ./sops/hm.nix
    ./fonts/hm.nix
    ./stylix/hm.nix
    ./wm/hyprland/hm.nix

    ./services/davmail/hm.nix
    ./services/dconf/hm.nix
    ./services/ha-notifier/hm.nix
    ./services/xremap/hm.nix

    ./apps/browsers/hm.nix
    ./apps/documents/hm.nix
    ./apps/email/hm.nix
    ./apps/kitty/hm.nix
    ./apps/misc/hm.nix
    ./apps/mpv/hm.nix
    ./apps/nvim/hm.nix
    ./apps/smartcalc-tui/hm.nix
    ./apps/spotify/hm.nix
    ./apps/ytsub/hm.nix

    ./shell/fish/hm.nix
    ./shell/jira-cli/hm.nix
    ./shell/misc/hm.nix
    ./shell/ngrok/hm.nix
    ./shell/tmux/hm.nix
  ];

  programs.home-manager.enable = true;
}
