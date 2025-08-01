{ name, ... }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { ... }:
    {
      options = {
        nether.software."${name}" =
          helpers.pkgOpt pkgs.direnv false
            "direnv - automatic per-project shell environments, with Nix devShell integration";
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether.software) direnv;
    in
    {
      programs.direnv = {
        inherit (direnv) enable package;
        silent = true;
        nix-direnv.enable = true;

        # Stolen from @isabelroses
        # modified from @i077O
        # store direnv in cache and not per project
        stdlib = ''
          : ''${XDG_CACHE_HOME:=$HOME/.cache}
          declare -A direnv_layout_dirs

          direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "$XDG_CACHE_HOME"/direnv/layouts/
              echo -n "$PWD" | sha1sum | cut -d ' ' -f 1
            )}"
          }
        '';
      };

      home.sessionVariables = lib.mkIf direnv.enable {
        DIRENV_WARN_TIMEOUT = "0";
      };
    };
}
