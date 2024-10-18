{ lib, pkgs, inputs, myUsername, myHostname, myTZ, myLocale, ... }:

{
  # Don't change without reading the documentation!
  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [
      ./apps/steam/system.nix
      ./hardware/hardware-configuration.nix
      ./hardware/nvidia.nix
      ./hardware/system76.nix
      ./hardware/audio.nix
      ./hardware/chrysalis.nix
      ./sops/system.nix
      ./fonts/system.nix
      ./stylix/system.nix
      ./wm/hyprland/system.nix
      ./services/peroxide/system.nix
      ./services/printing/system.nix
      ./services/xremap/system.nix

      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];


  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlay
  ];

  environment.systemPackages = with pkgs; [
    git
    neovim
  ];

  # Flatpak
  services.flatpak = {
    enable = true;
    packages = [ "app.bluebubbles.BlueBubbles" ];
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = myHostname; # Define your hostname.
  networking.networkmanager.enable = true;

  # Disable firewall.
  networking.firewall.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Set your time zone
  time.timeZone = myTZ;

  # Select internationalisation properties
  i18n.defaultLocale = myLocale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = myLocale;
    LC_IDENTIFICATION = myLocale;
    LC_MEASUREMENT = myLocale;
    LC_MONETARY = myLocale;
    LC_NAME = myLocale;
    LC_NUMERIC = myLocale;
    LC_PAPER = myLocale;
    LC_TELEPHONE = myLocale;
    LC_TIME = myLocale;
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account.
  users.users."${myUsername}" = {
    isNormalUser = true;
    description = myUsername;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Mount filesystems.
  fileSystems."/backup" = {
    device = "192.168.1.128:/storage/smb";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "noatime" "x-systemd.automount" "noauto" ];
  };

  security.pam.services.login.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Display manager.
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # Kill user processes on logout.
  services.logind.killUserProcesses = true;
}
