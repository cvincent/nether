{ name, mkSoftware, ... }:
mkSoftware name (
  { nether, gnome-keyring, ... }:
  {
    package = null;

    nixos = {
      services.gnome.gnome-keyring = { inherit (gnome-keyring) enable; };

      # Unlock the keyring on login
      security.pam.services.login.enableGnomeKeyring = gnome-keyring.enable;

      nether.backups.paths."${nether.homeDirectory}/.local/share/keyrings".deleteMissing = true;
    };
  }
)
