{ pkgs, ... }:

let
  home-assistant-desktop-receiver = (pkgs.callPackage ./pkg.nix {});
in {
  home.packages = [
    home-assistant-desktop-receiver
  ];

  systemd.user.services.ha-notifier = {
    Install.WantedBy = [ "network.target" ];

    Service = {
      ExecStart = "${home-assistant-desktop-receiver}/bin/home-assistant-desktop-receiver";
      Restart = "on-failure";
    };
  };
}
