{ pkgs, myHomeDir, ... }:

{
  sops.secrets."ngrok".path = "${myHomeDir}/.config/ngrok/ngrok.yml";
  home.packages = [ pkgs.ngrok ];
}
