{ inputs, ... }:

{
  imports = [ inputs.ha-notifier.homeManagerModules.default ];
  services.ha-notifier.enable = true;
}
