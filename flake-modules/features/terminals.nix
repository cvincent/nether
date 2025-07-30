{ name, ... }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  imports = [ (import ../software/kitty { name = "kitty"; }) ];

  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    {
      options = {
        nether.terminals = {
          kitty = helpers.pkgOpt pkgs.kitty (
            config.nether.terminals.default == "kitty"
          ) "Kitty terminal emulator";

          default = {
            which = lib.mkOption {
              type = lib.types.enum [
                null
                "kitty"
              ];
              default = null;
            };

            package = lib.mkOption { type = lib.types.package; };
            path = lib.mkOption { type = lib.types.str; };
          };
        };
      };

      config.nether.terminals.default = lib.mkIf (config.nether.terminals.default.which != null) {
        package = lib.mkForce config.nether.terminals."${config.nether.terminals.default.which}".package;
        path = lib.mkForce "${config.nether.terminals.default.package}/bin/${config.nether.terminals.default.which}";
      };
    }
  );
}
