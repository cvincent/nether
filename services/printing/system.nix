{ pkgs, myUsername, ... }:

{
  services.printing.enable = true;

  # Supports pretty much any "Apple compatible" printer, without drivers
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  # Scanning
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  users.users."${myUsername}".extraGroups = ["scanner" "lp"];
}
