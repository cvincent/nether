{ name, mkFeature, ... }:
mkFeature name (
  {
    user,
    lib,
    inputs,
    ...
  }:
  {
    options = {
      username = lib.mkOption { type = lib.types.str; };
      homeDirectory = lib.mkOption { type = lib.types.str; };

      dotfilesDirectory = lib.mkOption {
        type = lib.types.str;
        default = "${user.homeDirectory}/dotfiles";
      };

      downloadsDirectory = lib.mkOption {
        type = lib.types.str;
        default = "${user.homeDirectory}/Downloads";
      };

      homeSrcDirectory = lib.mkEnableOption "Backup and restore source code for projects I'm working on";
      me.fullName = lib.mkOption { type = lib.types.str; };
      me.email = lib.mkOption { type = lib.types.str; };
    };

    nixos = {
      users.users."${user.username}" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };

      nether.user = {
        homeDirectory = "/home/${user.username}";
        me.fullName = "Chris Vincent";
        me.email = inputs.private-nethers.email;
      };

      nether.backups.paths = {
        "${user.dotfilesDirectory}".deleteMissing = true;
        "${user.homeDirectory}/src" = lib.mkIf user.homeSrcDirectory {
          deleteMissing = true;
        };
      };
    };
  }
)
