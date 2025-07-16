{ name }:
{ lib, moduleWithSystem, ... }:
{
  imports = [ (import ./fish { name = "fish"; }) ];

  flake.nixosModules."${name}" = {
    options = {
      nether.shells = {
        fish.enable = lib.mkEnableOption "Fish shell";
        extraUtils.enable = lib.mkEnableOption "Various useful shell utilities";

        # TODO: Propagate this where we currently reference fish
        default = lib.mkOption {
          type = lib.types.enum [
            null
            "fish"
          ];
          default = null;
        };
      };
    };
  };

  # TODO: Make this more modular
  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
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
