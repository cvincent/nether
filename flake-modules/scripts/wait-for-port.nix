{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = {
    options.nether.scripts.waitForPort.enable =
      lib.mkEnableOption "Script to block until the given port is open";
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.scripts.waitForPort.enable {
        home.packages = [
          (pkgs.writeShellApplication {
            name = "wait-for-port";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.netcat-gnu
            ];
            text = ''
              port=''${1:-}
              echo "Waiting for port $port..."
              while ! nc -z localhost "$port"; do
                sleep 0.1
              done
            '';
          })
        ];
      };
    }
  );
}
