{ name }:
{ ... }:
{
  flake.nixosModules."${name}" = {
    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operator"
      ];
    };

    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
  };
}
