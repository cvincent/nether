{ name }:
moduleArgs@{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
helpers.flakeModule name moduleArgs {
  nixos = {
    options = {
      nether.chat.enable = lib.mkEnableOption "The many chat apps of the Internet";
    };
  };
}
