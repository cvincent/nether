{ name }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  imports = [ (import ./kitty { name = "kitty"; }) ];

  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    {
      options = {
        nether.terminals = {
          kitty = helpers.pkgOpt pkgs.kitty (
            config.nether.terminals.default == "kitty"
          ) "Kitty terminal emulator";

          # TODO: Propagate this where we currently reference kitty
          default = lib.mkOption {
            type = lib.types.enum [
              null
              "kitty"
            ];
            default = null;
          };

          defaultPackage = lib.mkOption { type = lib.types.package; };
          defaultPath = lib.mkOption { type = lib.types.str; };
        };
      };

      config.nether.terminals.defaultPackage = lib.mkIf config.nether.terminals.default (
        lib.mkForce config.nether.terminals."${config.nether.terminals.default}".package
      );

      config.nether.terminals.defaultPath = lib.mkIf config.nether.terminals.default (
        lib.mkForce "${config.nether.terminals.defaultPackage}/bin/${config.nether.terminals.default}"
      );
    }
  );
}
