{ myHomeDir, ... }:

{
  programs.aerc.enable = true;
  sops.secrets."aerc_accounts" = { path = "${myHomeDir}/.config/aerc/accounts.conf"; };
}
