{ name, mkSoftware, ... }:
mkSoftware name (
  { gnome-keyring, ... }:
  {
    package = null;

    nixos = {
      services.gnome.gnome-keyring = { inherit (gnome-keyring) enable; };

      # Unlock the keyring on login
      security.pam.services.login.enableGnomeKeyring = gnome-keyring.enable;
    };
  }
)
