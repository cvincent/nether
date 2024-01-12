{ ... }:

{
  # NOTE: We should eventually not need this line here, see
  # https://github.com/NixOS/nixpkgs/issues/158025
  security.pam.services.swaylock = {};
}
