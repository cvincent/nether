{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.homeModules."${name}" = moduleWithSystem (
    { pkgInputs }:
    { osConfig, utils, ... }:
    {
      config = lib.mkIf osConfig.nether.terminals.kitty.enable {
        home.packages = [ pkgInputs.nixpkgs-kitty.kitty ];
        home.file."./.config/kitty/kitty.conf".source = utils.directSymlink ./configs/kitty.conf;
        home.file."./.config/kitty/nord.conf".source = utils.directSymlink ./configs/nord.conf;
      };
    }
  );
}
