{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
  ];

  nether = {
    username = "cvincent";
    system.stateVersion = "24.11";
    home.stateVersion = "23.11";

    networking = {
      networkmanager.enable = true;
      openssh.enable = true;
      tor.enable = true;
    };

    graphicalEnv = {
      enable = true;
      enableGnomeKeyring = true;
      displayManager = "gdm";
    };

    editors = {
      neovim.enable = true;
      default = "neovim";
    };

    hardware = {
      audio.enable = true;
      chrysalis.enable = true;
      nvidia.enable = true;
    };

    flatpak.enable = true;
    homeAssistant.enable = true;
    ios.enable = true;
    mail.enable = true;
    printing2D.enable = true;
    steam.enable = true;
    windowsVM.enable = true;
    xremap = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_6_11;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kill user processes on logout
  services.logind.killUserProcesses = true;

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
}
