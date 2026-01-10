{ name, mkSoftware, ... }:
mkSoftware name (
  {
    jq,
    pkgs,
    config,
    ...
  }:
  {
    hm = {
      programs.jq = {
        inherit (jq) enable package;
      };

      home.packages = [
        (pkgs.writeShellApplication {
          name = "jq-preview";

          runtimeInputs = [
            pkgs.coreutils
            config.nether.software.fzf.fzf-with-opts
            config.nether.software.jq.package
          ];

          text = builtins.readFile ./jq-preview.bash;
        })
      ];
    };
  }
)
