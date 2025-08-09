{ inputs', ... }:
{ config, pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  nether = {
    username = "cvincent";

    nix = {
      enable = true;
      stateVersion = "25.05";
    };

    hardware = {
      chrysalis.enable = true;
    };

    networking = {
      enable = true;
      networkmanager.enable = true;
      openssh.enable = true;
      tor.enable = true;
    };

    shells = {
      enable = true;
      default.which = "fish";
    };

    terminals = {
      enable = true;
      default.which = "kitty";
    };

    editors = {
      enable = true;
      default.which = "neovim";
      # TODO: We should be able to juse use inputs' throughout
      neovim.package = inputs'.nixpkgs-neovim.legacyPackages.neovim;

      formatters.nixfmt-rfc-style.package =
        inputs'.nixpkgs-unstable-latest.legacyPackages.nixfmt-rfc-style;

      lsps = {
        nil.package = inputs'.nil-ls.packages.nil;
        # NOTE: Shouldn't we be able to use inputs' at least for all nixpkgs?
        nixd.package = inputs'.nixpkgs-unstable-latest.legacyPackages.nixd;
      };
    };

    graphicalEnv = {
      enable = true;
      primaryDisplay = "DP-1";

      displayManager.default.which = "gdm";

      compositor = {
        default.which = "hyprland";
        hyprland.package = inputs'.hyprland.packages.hyprland;
      };

      launcher.default.which = "fuzzel";
      bar.default.which = "waybar";

      notifications = {
        default.which = "swaync";
        swaync.package = inputs'.nixpkgs-unstable-latest.legacyPackages.swaynotificationcenter;
      };

      wallpapers.default.which = "swww";

      screenLocker = {
        default.which = "swaylock";
        swayidle.sleep.enable = false;
      };
    };

    media = {
      enable = true;
      apps.yt-dlp.package = inputs'.nixpkgs-yt-dlp.legacyPackages.yt-dlp;
    };

    homeSrcDirectory = true;

    dev = {
      enable = true;
      beam.enable = true;
      postgresql.enable = true;
      ruby.enable = true;
    };

    # Note for the future on structure/organization, I wonder if these should be
    # nested within graphicalEnv when they're apps that wouldn't work without
    # one...
    audio.enable = true;
    backups.enable = true;
    bitwarden.enable = true;

    browsers = {
      enable = true;
      qutebrowser.package = inputs'.nixpkgs-qutebrowser.legacyPackages.qutebrowser;
    };

    chat.enable = true;
    flatpak.enable = true;
    git.enable = true;
    homeAssistant.enable = true;
    ios.enable = true;
    jiraCLI.enable = true;
    lf.enable = true;
    mail.enable = true;

    misc = {
      enable = true;
      apps = {
        ryujinx.package = inputs'.nixpkgs-unstable-latest.legacyPackages.ryujinx;
        shadps4.package = inputs'.nixpkgs-unstable-latest.legacyPackages.shadps4;
      };
    };

    ngrok.enable = true;
    nvidia.enable = true;
    printing2d.enable = true;
    smartCalcTUI.enable = true;
    steam.enable = true;

    theme.enable = true;

    tmux = {
      enable = true;
      # TODO: See if we can get rid of this override. We need to check if the
      # currently packaged version has the scroll top/middle/bottom working
      # still.
      package = inputs'.nixpkgs-tmux.legacyPackages.tmux;
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
