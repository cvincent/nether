{ name, mkSoftware, ... }:
mkSoftware name (
  {
    jq,
    pkgs,
    config,
    lib,
    ...
  }:
  {
    options.tools = {
      jq-preview = lib.mkOption {
        type = lib.types.package;
        default = pkgs.writeShellApplication {
          name = "jq-preview";

          runtimeInputs = [
            pkgs.coreutils
            config.nether.software.fzf.fzf-with-opts
            config.nether.software.jq.package
          ];

          text = builtins.readFile ./jq-preview.bash;
        };
      };
    };

    hm = {
      programs.jq = {
        inherit (jq) enable package;
      };

      home.packages = jq.tools |> builtins.attrValues;
    };
  }
)
