{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    networking,
    lib,
    ...
  }:
  {
    options = {
      hostname = lib.mkOption { type = lib.types.str; };

      firewall.enable = lib.mkEnableOption "Linux firewall";
      openssh.enable = lib.mkEnableOption "OpenSSH";
      tor.enable = lib.mkEnableOption "Tor";
    };

    networkmanager = {
      networkmanagerapplet = { };
    };

    nixos = {
      networking.hostName = networking.hostname;
      networking.networkmanager.enable = networking.networkmanager.enable;
      networking.firewall.enable = networking.firewall.enable;
      services.openssh.enable = networking.openssh.enable;
      services.tor.client.enable = networking.tor.enable;

      users.users."${nether.username}" = lib.mkIf nether.networking.networkmanager.enable {
        extraGroups = [ "networkmanager" ];
      };
    };
  }
)
