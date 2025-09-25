{ inputs', pkgInputs, ... }:
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ./hardware.nix ];

  nether = {
    user = {
      enable = true;
      username = "cvincent";
      homeSrcDirectory = true;
    };

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

      formatters.nixfmt-rfc-style.package = inputs'.nixpkgs-unstable.legacyPackages.nixfmt-rfc-style;

      lsps = {
        nil.package = inputs'.nil-ls.packages.nil;
        # NOTE: Shouldn't we be able to use inputs' at least for all nixpkgs?
        nixd.package = inputs'.nixpkgs-unstable.legacyPackages.nixd;
      };
    };

    graphicalEnv = {
      enable = true;
      primaryDisplay = "DP-1";

      displayManager.default.which = "gdm";

      compositor = {
        default.which = "hyprland";
        hyprland.package = inputs'.hyprland.packages.hyprland;

        niri = {
          enable = false;
          package = pkgs.niri-unstable.override { src = inputs.niri-with-blur; };
        };
      };

      launcher.default.which = "fuzzel";
      bar.default.which = "waybar";

      notifications = {
        default.which = "swaync";
        swaync.package = inputs'.nixpkgs-unstable.legacyPackages.swaynotificationcenter;
      };

      wallpapers.default.which = "swww";

      screenLocker = {
        default.which = "swaylock";
        swayidle.sleep.enable = false;
      };

      extra.gnome-polkit.enable = false;
    };

    media = {
      enable = true;
      apps.yt-dlp.package = inputs'.nixpkgs-yt-dlp.legacyPackages.yt-dlp.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "yt-dlp";
          repo = "yt-dlp";
          rev = "2025.09.23";
          hash = "sha256-pqdR1JfiqvBs5vSKF7bBBKqq0DRAi3kXCN1zDvaW3nQ=";
        };
      };

      apps.spotify.package = pkgInputs.nixpkgs-spotify.spotify;
    };

    dev = {
      enable = true;
      beam.enable = true;
      c.enable = true;
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
        bambu-studio.package = inputs'.nixpkgs-bambu-studio.legacyPackages.bambu-studio;
        ryubing.package = inputs'.nixpkgs-unstable.legacyPackages.ryubing;
        shadps4.package = inputs'.nixpkgs-unstable.legacyPackages.shadps4;
      };
    };

    ngrok.enable = true;
    notes.enable = true;
    nvidia.enable = true;
    printing2d.enable = true;
    smartCalcTUI.enable = true;
    steam.enable = true;

    theme.enable = true;
    timeAndLocale.enable = true;

    tmux = {
      enable = true;
      package = inputs'.nixpkgs-unstable.legacyPackages.tmux;
    };

    windowsVM.enable = true;
    xremap = true;

    # TODO: Convert scripts to mkSoftware; enable wait-for-port as part of the
    # dev feature; invoice-generator can stay here
    scripts.invoice-generator.enable = true;
    scripts.wait-for-port.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_6_15;
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
