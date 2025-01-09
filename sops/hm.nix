{
  pkgs,
  inputs,
  myHomeDir,
  ...
}:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix
  ];

  home.packages = [ pkgs.sops ];

  sops.defaultSymlinkPath = "${myHomeDir}/.config/sops/secrets";
  sops.defaultSecretsMountPoint = "${myHomeDir}/.config/sops/secrets.d";

  sops.secrets."ssh/public_key" = {
    path = "${myHomeDir}/.ssh/id_rsa.pub";
  };
  sops.secrets."ssh/private_key" = {
    path = "${myHomeDir}/.ssh/id_rsa";
  };
}
