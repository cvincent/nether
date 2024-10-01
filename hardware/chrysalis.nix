{ config, lib, nixpkgs-unstable, modulesPath, ... }:

{
  environment.systemPackages = [ nixpkgs-unstable.chrysalis ];
  services.udev.packages = [ nixpkgs-unstable.chrysalis ];
}
