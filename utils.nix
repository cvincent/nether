{ config, ... }:

{
  _module.args.utils.directSymlink =
    path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";
}
