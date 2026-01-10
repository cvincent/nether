{ name, ... }:
# Convenience for accessing common options
{
  flake.nixosModules."${name}" =
    { config, lib, ... }:
    {
      options = {
        nether.username = lib.mkOption { type = lib.types.str; };
        nether.homeDirectory = lib.mkOption { type = lib.types.str; };
        nether.dotfilesDirectory = lib.mkOption { type = lib.types.str; };
        nether.downloadsDirectory = lib.mkOption { type = lib.types.str; };
        nether.me = lib.mkOption { type = with lib.types; attrsOf anything; };
      };

      config = {
        nether.username = config.nether.user.username;
        nether.homeDirectory = config.nether.user.homeDirectory;
        nether.dotfilesDirectory = config.nether.user.dotfilesDirectory;
        nether.downloadsDirectory = config.nether.user.downloadsDirectory;
        nether.me = config.nether.user.me;
      };
    };
}
