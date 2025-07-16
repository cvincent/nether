{ name }:
{
  lib,
  moduleWithSystem,
  inputs,
  ...
}:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.bitwarden.enable = lib.mkEnableOption "BitWarden password/secrets management and helper scripts";

        nether.bitwarden.helperScripts.enable = lib.mkOption {
          type = lib.types.bool;
          description = "Helper scripts for integrating BitWarden with other programs, such as Fuzzel";
          default = config.nether.bitwarden.enable;
        };
      };
    };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    {
      osConfig,
      utils,
      ...
    }:
    let
      bitwarden-cache-vault = (
        pkgs.writeShellScriptBin "bitwarden-cache-vault" (builtins.readFile ./bitwarden-cache-vault.bash)
      );
    in
    {
      # TODO: Consider checking whether Fuzzel is installed before installing
      # those integration scripts
      config = lib.mkIf osConfig.nether.bitwarden.enable {
        home.packages = [
          pkgs.bitwarden-cli
          pkgs.oath-toolkit

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

        home.file."./.local/share/bitwarden/templates".source =
          utils.directSymlink "flake-modules/bitwarden/templates";

        home.file."./.local/share/bitwarden/client_id".text = inputs.private-nethers.bitwarden.clientId;
        home.file."./.local/share/bitwarden/client_secret".text =
          inputs.private-nethers.bitwarden.clientSecret;
        home.file."./.local/share/bitwarden/password".text = inputs.private-nethers.bitwarden.password;

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
      };
    }
  );
}
