{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
  ];

  nether = {
    username = "cvincent";
    system.stateVersion = "24.11";
    home.stateVersion = "23.11";

    networkmanager.enable = true;
    tor.enable = true;

    graphicalEnv = {
      enable = true;
      displayManager = "gdm";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_6_11;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
