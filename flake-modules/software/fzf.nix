{ name, mkSoftware, ... }:
mkSoftware name (
  {
    fzf,
    lib,
    pkgs,
    hmConfig,
    ...
  }:
  {
    options.fzf-with-opts = lib.mkOption {
      type = lib.types.package;
      default = (
        pkgs.writeShellApplication {
          name = "fzf";
          runtimeInputs = [ fzf.package ];
          runtimeEnv = {
            inherit (hmConfig.home.sessionVariables) FZF_DEFAULT_OPTS;
          };
          text = ''fzf "$@"'';
        }
      );
    };

    hm.programs.fzf = {
      inherit (fzf) enable package;

      defaultOptions =
        let
          bind =
            {
              ctrl-h = "backward-kill-word";
              ctrl-left = "backward-word";
              ctrl-right = "forward-word";
            }
            |> lib.mapAttrsToList (k: v: "${k}:${v}")
            |> builtins.concatStringsSep ",";
        in
        [
          "--bind=${bind}"
        ];

      colors.bg = lib.mkForce "-1";
    };
  }
)
