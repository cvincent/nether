{ pkgs, myUsername, ... }:

{
  security.polkit = {
    enable = true;
    adminIdentities = ["unix-user:${myUsername}"];
  };
}
