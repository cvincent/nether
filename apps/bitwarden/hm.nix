{ pkgs, myHomeDir, ... }:

{
  home.packages = [
    pkgs.bitwarden-cli
    (pkgs.writeShellScriptBin "bitwarden-ensure-session" (
      builtins.readFile ./bitwarden-ensure-session.bash
    ))
    (pkgs.writeShellScriptBin "bitwarden-qutebrowser" (builtins.readFile ./bitwarden-qutebrowser.bash))
    (pkgs.writeShellScriptBin "bitwarden-cache-vault" (builtins.readFile ./bitwarden-cache-vault.bash))
    (pkgs.writeShellScriptBin "bitwarden-search-vault" (
      builtins.readFile ./bitwarden-search-vault.bash
    ))
    (pkgs.writeShellScriptBin "bitwarden-fuzzel" (builtins.readFile ./bitwarden-fuzzel.bash))
    (pkgs.writeShellScriptBin "bitwarden-edit" (builtins.readFile ./bitwarden-edit.bash))
  ];

  sops.secrets."bitwarden/client_id" = {
    path = "${myHomeDir}/.local/share/bitwarden/client_id";
  };
  sops.secrets."bitwarden/client_secret" = {
    path = "${myHomeDir}/.local/share/bitwarden/client_secret";
  };
  sops.secrets."bitwarden/password" = {
    path = "${myHomeDir}/.local/share/bitwarden/password";
  };
}
