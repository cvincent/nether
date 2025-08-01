{ name, ... }:
{ lib, moduleWithSystem, ... }:
{
  flake.homeModules."${name}" = moduleWithSystem (
    { pkgInputs }:
    { osConfig, helpers, ... }:
    {
      config = lib.mkIf osConfig.nether.terminals.kitty.enable {
        home.packages = [ pkgInputs.nixpkgs-kitty.kitty ];

        home.file."./.config/kitty/generated.conf".text = ''
          shell ${osConfig.nether.shells.default.path}
        '';

        home.file."./.config/kitty/kitty.conf".source = helpers.directSymlink ./configs/kitty.conf;
        home.file."./.config/kitty/nord.conf".source = helpers.directSymlink ./configs/nord.conf;
      };
    }
  );
}
