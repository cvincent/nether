{ ... }:

{
  # We probably don't need separate directories or files for every little
  # service; or we should have ./services/system.nix and ./services/hm.nix and
  # have them bring in the subdirectories as needed...kinda like Snowfall!

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Silences warnings on Chromium boot, and useful for checking battery levels
  # from CLI
  services.upower.enable = true;

  services.flatpak = {
    enable = true;
    # Will probably eventually move this line elsewhere, especially when/if we
    # add more Flatpaks
    packages = [ "app.bluebubbles.BlueBubbles" ];
  };

  # TLP, for future reference
  # services.tlp = {
  #   enable = false;
  #   settings = {
  #      # These don't work, neither does setting them via system76-power...
  #      START_CHARGE_THRESH_BAT0 = 96; # 40 and bellow it starts to charge
  #      STOP_CHARGE_THRESH_BAT0 = 100; # 80 and above it stops charging
  #    };
  #  };
}
