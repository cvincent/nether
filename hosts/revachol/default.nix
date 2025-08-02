{ pkgInputs, inputs' }:
{ config, pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  nether = {
    username = "cvincent";

    system.stateVersion = "25.05";
    home.stateVersion = "25.05";

    hardware = {
      audio.enable = true;
      chrysalis.enable = true;
      nvidia.enable = true;
    };

    networking = {
      networkmanager.enable = true;
      openssh.enable = true;
      tor.enable = true;
    };

    shells = {
      fish.enable = true;
      extra.enable = true;
      default.which = "fish";
    };

    terminals = {
      kitty.enable = true;
      default.which = "kitty";
    };

    editors = {
      neovim.enable = true;
      default = "neovim";
    };

    graphicalEnv = {
      enable = true;
      displayManager = "gdm";

      compositor = {
        which = "hyprland";
        hyprland.package = inputs'.hyprland.packages.hyprland;
      };

      launcher.which = "fuzzel";
      bar.which = "waybar";
      notifications.which = "swaync";
      wallpapers.which = "swww";

      screenLocker = {
        which = "swaylock";
        swaylock.package = pkgInputs.nixpkgs-unstable.swaylock;
      };
    };

    media = {
      enable = true;
      apps.ytDlp.package = pkgInputs.nixpkgs-yt-dlp.yt-dlp;
    };

    homeSrcDirectory = true;

    dev.beam.enable = true;
    dev.postgresql.enable = true;
    dev.ruby.enable = true;

    # Note for the future on structure/organization, I wonder if these should be
    # nested within graphicalEnv when they're apps that wouldn't work without
    # one...
    backups.enable = true;
    bitwarden.enable = true;
    browsers.enable = true;
    chat.enable = true;
    flatpak.enable = true;
    git.enable = true;
    homeAssistant.enable = true;
    ios.enable = true;
    jiraCLI.enable = true;
    lf.enable = true;
    mail.enable = true;
    miscApps.enable = true;
    ngrok.enable = true;
    printing2D.enable = true;
    smartCalcTUI.enable = true;
    steam.enable = true;

    tmux = {
      enable = true;
      # TODO: See if we can get rid of this override. We need to check if the
      # currently packaged version has the scroll top/middle/bottom working
      # still.
      package = pkgInputs.nixpkgs-tmux.tmux;
    };

    windowsVM.enable = true;
    xremap = true;

    scripts.invoiceGenerator.enable = true;
    scripts.waitForPort.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kill user processes on logout
  services.logind.killUserProcesses = true;

  fileSystems."${config.nether.homeDirectory}/art" = {
    device = "/dev/disk/by-uuid/8c65989a-12bd-4bee-8e40-c8679eb49a6a";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/steam" = {
    device = "/dev/disk/by-uuid/2749d5f5-c6c6-4a62-abe2-8ebcfb0bc68a";
    fsType = "ext4";
    options = [ "nofail" ];
  };
}
