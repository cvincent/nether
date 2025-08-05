{ name, mkSoftware, ... }:
mkSoftware name (
  { swaylock, lib, ... }:
  {
    nixos.security.pam.services.swaylock = { };

    hm.programs.swaylock = {
      inherit (swaylock) enable package;

      settings = {
        image = lib.mkForce false;
        daemonize = true;
      };
    };
  }
)
