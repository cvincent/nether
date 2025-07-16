{
  pkgs,
  lib,
  myUsername,
  myHomeDir,
  ...
}:

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
    ./services/davmail/hm.nix
    ./services/dconf/hm.nix
    ./services/ha-notifier/hm.nix
    ./services/windows-vm/hm.nix
    ./services/xremap/hm.nix

    ./apps/bitwarden/hm.nix
    ./apps/browsers/hm.nix
    ./apps/documents/hm.nix
    ./apps/kitty/hm.nix
    ./apps/mpv/hm.nix
    ./apps/nvim/hm.nix
    ./apps/spotify/hm.nix # skipping, this is ncspot which we don't use anymore
    ./apps/ytsub/hm.nix # skipping, we don't use it

    ./shell/fish/hm.nix
    # separate shell "essentials" next
    ./shell/jira-cli/hm.nix
    ./shell/misc/hm.nix
    ./shell/ngrok/hm.nix
    ./shell/tmux/hm.nix

    ./apps/smartcalc-tui/hm.nix # Come back to this, let's figure out how we want to do custom packages
    ./apps/misc/hm.nix
    ./apps/email/hm.nix
    ./wm/hyprland/hm.nix
    ./sops/hm.nix
    ./fonts/hm.nix
    ./stylix/hm.nix
  ];

  programs.home-manager.enable = true;
}
