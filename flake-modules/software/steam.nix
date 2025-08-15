{ name, ... }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgInputs }:
    { config, ... }:
    {
      options = {
        nether.steam.enable = lib.mkEnableOption "Steam";
      };

      config = lib.mkIf config.nether.steam.enable {
        programs.steam.enable = true;
        environment.systemPackages = [
          pkgInputs.nixpkgs-unstable.protonup-qt
          pkgInputs.nixpkgs-unstable.protontricks
        ];

        # TODO: These should be pulled up into the gaming.nix feature when we
        # define it; mkSoftware modules shouldn't be defining nether options
        nether.backups.paths = {
          "${config.nether.homeDirectory}/.local/share/Steam/config".deleteMissing = true;
          "${config.nether.homeDirectory}/.local/share/Steam/userdata".deleteMissing = true;
        };
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.steam.enable {
        xdg.mimeApps = {
          enable = true;
          defaultApplications."x-scheme-handler/steam" = "steam.desktop";
        };
      };
    };
}
