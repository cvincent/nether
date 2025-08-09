{ name, ... }:
{ lib, inputs, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.username = lib.mkOption { type = lib.types.str; };
        nether.homeDirectory = lib.mkOption { type = lib.types.str; };

        nether.dotfilesDirectory = lib.mkOption {
          type = lib.types.str;
          default = "${config.nether.homeDirectory}/dotfiles";
        };

        nether.homeSrcDirectory = lib.mkEnableOption "Backup and restore source code for projects I'm working on";
        nether.me.fullName = lib.mkOption { type = lib.types.str; };
        nether.me.email = lib.mkOption { type = lib.types.str; };
      };

      config = {
        users.users."${config.nether.username}" = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };

        nether.homeDirectory = "/home/${config.nether.username}";
        nether.me.fullName = "Chris Vincent";
        nether.me.email = inputs.private-nethers.email;

        nether.backups.paths = {
          "${config.nether.dotfilesDirectory}".deleteMissing = true;
          "${config.nether.homeDirectory}/src" = lib.mkIf config.nether.homeSrcDirectory {
            deleteMissing = true;
          };
        };
      };
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      home.username = osConfig.nether.username;
      home.homeDirectory = osConfig.nether.homeDirectory;
      xdg.mimeApps.enable = true;
    };
}
