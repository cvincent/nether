{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = [ pkgs.chrysalis ];
  services.udev.packages = [ pkgs.chrysalis ];
}
