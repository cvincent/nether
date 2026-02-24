{ name, mkSoftware, ... }:
mkSoftware name (
  {
    contextual-completion,
    pkgs,
    lib,
    ...
  }:
  let
    cases =
      contextual-completion.completionScripts
      |> lib.mapAttrsToList (cmd: scriptPackage: ''"${cmd}") ${lib.getExe scriptPackage}'')
      |> builtins.concatStringsSep "\n";

    script = pkgs.writeShellApplication {
      inherit name;
      text =
        if contextual-completion.completionScripts != { } then
          ''
            case $1 in
              ${cases} "$2";;
            esac
          ''
        else
          "exit 1";
    };
  in
  {
    options = {
      package = lib.mkOption {
        type = lib.types.package;
        default = script;
      };

      completionScripts = lib.mkOption {
        type = lib.types.attrsOf lib.types.package;
        default = { };
      };
    };
  }
)
