{ name }:
{
  lib,
  moduleWithSystem,
  inputs,
  ...
}:
{
  flake.nixosModules."${name}" = {
    options.nether.ngrok.enable = lib.mkEnableOption "Ngrok web publication tool";
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.ngrok.enable {
        home.packages = [ pkgs.ngrok ];
        home.file."./.config/ngrok/ngrok.yml".text = inputs.private-nethers.ngrokYml;
      };
    }
  );
}
