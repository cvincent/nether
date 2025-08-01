{ name, ... }:
{
  lib,
  moduleWithSystem,
  inputs,
  ...
}:
{
  # TODO: Currently this assumes your terminal and editor; these should be
  # agnostic
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
      bitwarden-cache-vault = pkgs.writeShellApplication {
        name = "bitwarden-cache-vault";
        text = builtins.readFile ./bitwarden-cache-vault.bash;
        runtimeInputs = with pkgs; [
          bitwarden-cli
          bitwarden-ensure-session
        ];
      };

      bitwarden-ensure-session = pkgs.writeShellApplication {
        name = "bitwarden-ensure-session";
        text = builtins.readFile ./bitwarden-ensure-session.bash;
        runtimeInputs = with pkgs; [
          bitwarden-cli
          coreutils
        ];
      };

      bitwarden-qutebrowser = pkgs.writeShellApplication {
        name = "bitwarden-qutebrowser";
        text = builtins.readFile ./bitwarden-qutebrowser.bash;
        runtimeInputs = with pkgs; [
          bitwarden-search-vault
          coreutils
        ];
      };

      bitwarden-search-vault = pkgs.writeShellApplication {
        name = "bitwarden-search-vault";
        text = builtins.readFile ./bitwarden-search-vault.bash;
        runtimeInputs = with pkgs; [
          bitwarden-cache-vault
          coreutils
        ];
      };

      bitwarden-fuzzel = pkgs.writeShellApplication {
        name = "bitwarden-fuzzel";
        text = builtins.readFile ./bitwarden-fuzzel.bash;
        runtimeInputs = with pkgs; [
          bitwarden-cache-vault
          bitwarden-cli
          bitwarden-edit
          bitwarden-ensure-session
          coreutils
          findutils
          gnused
          jq
          oath-toolkit
          osConfig.nether.graphicalEnv.extra.clipboardSupport.wlClipboard.package
          osConfig.nether.graphicalEnv.extra.clipboardSupport.cliphist.package
          osConfig.nether.graphicalEnv.launcher.fuzzel.package
          osConfig.nether.graphicalEnv.notifications.libnotify.package
        ];
      };

      bitwarden-fuzzel-create = (
        pkgs.writeShellApplication {
          name = "bitwarden-fuzzel-create";
          text = builtins.readFile ./bitwarden-fuzzel-create.bash;
          runtimeInputs = with pkgs; [
            bitwarden-cli
            bitwarden-create
            coreutils
            findutils
            gnused
            osConfig.nether.graphicalEnv.launcher.fuzzel.package
          ];
        }
      );

      bitwarden-edit = pkgs.writeShellApplication {
        name = "bitwarden-edit";
        text = builtins.readFile ./bitwarden-edit.bash;
        runtimeInputs = with pkgs; [
          bitwarden-cache-vault
          bitwarden-cli
          bitwarden-ensure-session
          coreutils
          jq
          osConfig.nether.graphicalEnv.launcher.fuzzel.package
          osConfig.nether.graphicalEnv.notifications.libnotify.package
          osConfig.nether.terminals.default.package
        ];
      };

      bitwarden-create = pkgs.writeShellApplication {
        name = "bitwarden-create";
        text = builtins.readFile ./bitwarden-create.bash;
        runtimeInputs = with pkgs; [
          bitwarden-cache-vault
          bitwarden-cli
          bitwarden-ensure-session
          coreutils
          jq
          osConfig.nether.graphicalEnv.launcher.fuzzel.package
          osConfig.nether.graphicalEnv.notifications.libnotify.package
          osConfig.nether.terminals.default.package
        ];
      };

      path =
        [
          pkgs.bitwarden-cli
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
