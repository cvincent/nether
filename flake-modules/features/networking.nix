{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    networking,
    lib,
    inputs,
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
      networkmanagerapplet.config.service.enable = true;
    };

    nixos = {
      networking = {
        hostName = networking.hostname;
        networkmanager.enable = networking.networkmanager.enable;
        firewall.enable = networking.firewall.enable;
        hosts = inputs.private-nethers.hosts;
      };

      services = {
        openssh.enable = networking.openssh.enable;
        tor.client.enable = networking.tor.enable;
      };

      users.users."${nether.username}" = lib.mkIf nether.networking.networkmanager.enable {
        extraGroups = [ "networkmanager" ];
      };
    };
  }
)
