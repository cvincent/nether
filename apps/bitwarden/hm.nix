{
  pkgs,
  myHomeDir,
  utils,
  ...
}:

let
  bitwarden-cache-vault = (
    pkgs.writeShellScriptBin "bitwarden-cache-vault" (builtins.readFile ./bitwarden-cache-vault.bash)
  );
in
{
  home.packages = [
    pkgs.bitwarden-cli
    bitwarden-cache-vault
    (pkgs.writeShellScriptBin "bitwarden-ensure-session" (
      builtins.readFile ./bitwarden-ensure-session.bash
    ))
    (pkgs.writeShellScriptBin "bitwarden-qutebrowser" (builtins.readFile ./bitwarden-qutebrowser.bash))
    (pkgs.writeShellScriptBin "bitwarden-search-vault" (
      builtins.readFile ./bitwarden-search-vault.bash
    ))
    (pkgs.writeShellScriptBin "bitwarden-fuzzel" (builtins.readFile ./bitwarden-fuzzel.bash))
    (pkgs.writeShellScriptBin "bitwarden-fuzzel-create" (
      builtins.readFile ./bitwarden-fuzzel-create.bash
    ))
    (pkgs.writeShellScriptBin "bitwarden-edit" (builtins.readFile ./bitwarden-edit.bash))
    (pkgs.writeShellScriptBin "bitwarden-create" (builtins.readFile ./bitwarden-create.bash))
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

  home.file."./.local/share/bitwarden/templates".source = utils.directSymlink "apps/bitwarden/templates";

  systemd.user.services.sync-bitwarden = {
    Unit.PartOf = [ "graphical.target" ];
    Unit.After = [ "graphical.target" ];
    Install.WantedBy = [ "graphical.target" ];
    Service.ExecStart = "${bitwarden-cache-vault}/bin/bitwarden-cache-vault";
    Service.Type = "oneshot";
  };

  systemd.user.timers.sync-bitwarden = {
    Install.WantedBy = [ "timers.target" ];
    Timer.OnCalendar = "*:00,10,20,30,40,50:00";
    Timer.AccuracySec = "1s";
  };
}
