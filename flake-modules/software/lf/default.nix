{ name, ... }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = {
    options.nether.lf.enable = lib.mkEnableOption "lf TUI file browser";
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.lf.enable {

        home.packages = [
          pkgs.file
        ];

        programs.lf = {
          enable = true;
          settings = {
            previewer = "~/.config/lf/previewer-kitty";
          };
        };

        home.file."./.config/lf/previewer-kitty".source = ./previewer-kitty;
      };
    }
  );
}
