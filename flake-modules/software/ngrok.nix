{ name, ... }:
{
  lib,
  moduleWithSystem,
  inputs,
  ...
}:
# TODO: Port to mkSoftware, enable and set config through networking.nix
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
        xdg.configFile."ngrok/ngrok.yml".text = inputs.private-nethers.ngrokYml;
      };
    }
  );
}
