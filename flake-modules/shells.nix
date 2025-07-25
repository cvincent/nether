{ name }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  imports = [ (import ./fish { name = "fish"; }) ];

  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    {
      options = {
        nether.shells = {
          fish = helpers.pkgOpt pkgs.fish (config.nether.shells.default == "fish") "Fish shell";
          extraUtils.enable = lib.mkEnableOption "Various useful shell utilities";

          default = lib.mkOption {
            type = lib.types.enum [
              null
              "fish"
            ];
            default = null;
          };

          defaultPath = lib.mkOption { type = lib.types.str; };
        };
      };

      config.nether.shells = lib.mkIf (config.nether.shells.default != null) {
        defaultPath = lib.mkForce "${
          config.nether.shells."${config.nether.shells.default}".package
        }/bin/${config.nether.shells.default}";
      };
    }
  );

  # TODO: Make this more modular
  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs, pkgInputs }:
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.shells.extraUtils.enable {
        home.packages = with pkgs; [
          bat # `cat` alternative
          btop # `top` alternative

          # `du`-like alternatives
          du-dust
          dua
          duf

          eza # `ls` alternative
          fd # `find` alternative
          fzf
          zf
          jq
          fx
          magic-wormhole
          unzip

          neofetch
          pkgInputs.nixpkgs-unstable-latest.gh

          (pkgs.writeShellScriptBin "wait-for-port" ''
            echo "Waiting for port $1..."
            while ! nc -z localhost $1; do
              sleep 0.1
            done
          '')

          (pkgs.writeShellScriptBin "jq-preview" ''
            #!/usr/bin/env bash
            if [[ -z $1 ]] || [[ $1 == "-" ]]; then
              input=$(mktemp)
              trap "rm -f $input" EXIT
              cat /dev/stdin > $input
            else
              input=$1
            fi

            echo "" | fzf \
              --phony \
              --preview-window='up:90%' \
              --print-query \
              --preview "jq --color-output -r {q} $input"
          '')
        ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        programs.zoxide = {
          enable = true;
          enableFishIntegration = osConfig.nether.shells.fish.enable;
        };

        programs.ripgrep = {
          enable = true;
          arguments = [
            "--glob=!*.enc"
          ];
        };

        home.sessionVariables = {
          ERL_AFLAGS = "-kernel shell_history enabled";
          FZF_DEFAULT_OPTS = "--bind=ctrl-h:backward-kill-word";
        };

        programs.starship = {
          enable = true;
          enableFishIntegration = osConfig.nether.shells.fish.enable;
        };
      };
    }
  );
}
