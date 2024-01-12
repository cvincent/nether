{ pkgs, myHomeDir, ... }:

{
  # Open source bridge for ProtonMail that works fine with aerc
  home.packages = [ pkgs.hydroxide ];
  sops.secrets."hydroxide_auth" = { path = "${myHomeDir}/.config/hydroxide/auth.json"; };
}
