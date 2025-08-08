{ name, mkFeature, ... }:
mkFeature name (
  { pkgs, ... }:
  {
    nixos = {
      environment.systemPackages = with pkgs; [
        libimobiledevice
        ifuse
      ];

      services.usbmuxd = {
        enable = true;
        package = pkgs.usbmuxd2;
      };
    };
  }
)
