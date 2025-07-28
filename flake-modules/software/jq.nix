{ name }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    {
      options = {
        nether.software.jq = (helpers.pkgOpt pkgs.jq false "jq - CLI JSON processor");
      };
    }
  );

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    let
      inherit (osConfig.nether.software) jq;
    in
    {
      config = lib.optionalAttrs jq.enable {
        programs.jq = jq;

        home.packages = [
          (pkgs.writeShellApplication {
            name = "jq-preview";

            runtimeInputs = [
              pkgs.coreutils
              osConfig.nether.software.fzf.package
              osConfig.nether.software.jq.package
            ];

            text = ''
              input=''${1:-}

              if [[ -z $input ]] || [[ $input == "-" ]]; then
                input=$(mktemp)
                trap 'rm -f $input' EXIT
                cat /dev/stdin > "$input"
              fi

              echo "" | fzf \
                --phony \
                --preview-window='up:90%' \
                --print-query \
                --preview "jq --color-output -r {q} $input"
            '';
          })
        ];
      };
    }
  );
}
