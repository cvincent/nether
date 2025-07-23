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
      helpers,
      ...
    }:
    let
      bitwarden-cli = pkgs.bitwarden-cli;

      bitwarden-cache-vault = (
        pkgs.writeShellScriptBin "bitwarden-cache-vault" (builtins.readFile ./bitwarden-cache-vault.bash)
      );
      bitwarden-ensure-session = (
        pkgs.writeShellScriptBin "bitwarden-ensure-session" (
          builtins.readFile ./bitwarden-ensure-session.bash
        )
      );
      bitwarden-qutebrowser = (
        pkgs.writeShellScriptBin "bitwarden-qutebrowser" (builtins.readFile ./bitwarden-qutebrowser.bash)
      );
      bitwarden-search-vault = (
        pkgs.writeShellScriptBin "bitwarden-search-vault" (builtins.readFile ./bitwarden-search-vault.bash)
      );
      bitwarden-fuzzel = (
        pkgs.writeShellScriptBin "bitwarden-fuzzel" (builtins.readFile ./bitwarden-fuzzel.bash)
      );
      bitwarden-fuzzel-create = (
        pkgs.writeShellScriptBin "bitwarden-fuzzel-create" (
          builtins.readFile ./bitwarden-fuzzel-create.bash
        )
      );
      bitwarden-edit = (
        pkgs.writeShellScriptBin "bitwarden-edit" (builtins.readFile ./bitwarden-edit.bash)
      );
      bitwarden-create = (
        pkgs.writeShellScriptBin "bitwarden-create" (builtins.readFile ./bitwarden-create.bash)
      );

      path =
        [
          bitwarden-cli
          bitwarden-cache-vault
          bitwarden-ensure-session
          bitwarden-qutebrowser
          bitwarden-search-vault
          bitwarden-fuzzel
          bitwarden-fuzzel-create
          bitwarden-edit
          bitwarden-create
        ]
        |> builtins.map (pkg: "${pkg}/bin")
        |> lib.strings.concatStringsSep ":";
    in
    {
      # TODO: Consider checking whether Fuzzel is installed before installing
      # those integration scripts
      config = lib.mkIf osConfig.nether.bitwarden.enable {
        home.packages = [
          pkgs.bitwarden-cli
          pkgs.oath-toolkit

          bitwarden-cache-vault
          bitwarden-ensure-session
          bitwarden-qutebrowser
          bitwarden-search-vault
          bitwarden-fuzzel
          bitwarden-fuzzel-create
          bitwarden-edit
          bitwarden-create
        ];

        home.file."./.local/share/bitwarden/templates".source = helpers.directSymlink ./templates;

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
          Service.Environment = "PATH=${path}";
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
