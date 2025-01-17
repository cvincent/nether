{
  pkgs,
  inputs,
  myUsername,
  myHostname,
  myTZ,
  myLocale,
  ...
}:

{
  # Don't change without reading the documentation!
  system.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_11;

  imports = [
    ./apps/nvim/system.nix
    ./apps/steam/system.nix
    ./hardware/hardware-configuration.nix
    ./hardware/nvidia.nix
    ./hardware/audio.nix
    ./hardware/chrysalis.nix
    ./sops/system.nix
    ./fonts/system.nix
    ./stylix/system.nix
    ./wm/hyprland/system.nix
    ./services/ios/system.nix
    ./services/misc/system.nix
    ./services/peroxide/system.nix
    ./services/printing/system.nix
    ./services/windows-vm/system.nix
    ./services/xremap/system.nix

    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  environment.systemPackages = with pkgs; [
    git
    neovim
    sshfs
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = myHostname; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Time and locale
  time.timeZone = myTZ;
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
    displayManager.gdm.enable = true;
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account
  users.users."${myUsername}" = {
    isNormalUser = true;
    description = myUsername;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Mount filesystems
  fileSystems."/steam" = {
    device = "/dev/disk/by-uuid/2749d5f5-c6c6-4a62-abe2-8ebcfb0bc68a";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/backup" = {
    device = "192.168.1.128:/storage/smb";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "noatime"
      "nofail"
    ];
  };

  # Periodically optimize the store to save disk
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  # Kill user processes on logout
  services.logind.killUserProcesses = true;
}
