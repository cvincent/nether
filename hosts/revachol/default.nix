{ ... }:
{
  imports = [
    ./hardware.nix
  ];

  nether = {
    username = "cvincent";
    system.stateVersion = "24.11";
    home.stateVersion = "24.11";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
