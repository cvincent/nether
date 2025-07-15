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
  };

  boot.kernelPackages = pkgs.linuxPackages_6_11;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
