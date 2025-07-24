{ name }:
{ lib, moduleWithSystem, ... }:
let
  chromiumOverrides = {
    commandLineArgs = [
      "--enable-features=VaapiVideoEncoder"
      "--ignore-gpu-blocklist"
      "--enable-zero-copy"
    ];
  };
in
{
  imports = [ (import ./qutebrowser { name = "qutebrowser"; }) ];

  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options.nether.browsers = {
        enable = lib.mkEnableOption "Browsers for the World Wide Web";

        brave.enable = lib.mkOption {
          type = lib.types.bool;
          default = config.nether.browsers.enable;
        };

        chromium.enable = lib.mkOption {
          type = lib.types.bool;
          default = config.nether.browsers.enable;
        };

        firefox.enable = lib.mkOption {
          type = lib.types.bool;
          default = config.nether.browsers.enable;
        };

        qutebrowser.enable = lib.mkOption {
          type = lib.types.bool;
          default = config.nether.browsers.enable;
        };
      };

      config = lib.mkIf config.nether.browsers.enable {
        nether.backups.paths = {
          "${config.nether.homeDirectory}/Downloads".deleteMissing = true;

          "${config.nether.homeDirectory}/.config/BraveSoftware/Brave-Browser" =
            lib.mkIf config.nether.browsers.brave.enable
              { deleteMissing = true; };

          "${config.nether.homeDirectory}/.config/chromium" =
            lib.mkIf config.nether.browsers.chromium.enable
              {
                deleteMissing = true;
              };

          "${config.nether.homeDirectory}/.mozilla/firefox" = lib.mkIf config.nether.browsers.firefox.enable {
            deleteMissing = true;
          };
        };

        # Silences warnings on Chromium boot, and useful for checking battery levels
        # from CLI
        services.upower = lib.mkIf config.nether.browsers.chromium.enable { enable = true; };
      };
    };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      home.packages =
        [ ]
        ++ (lib.optional osConfig.nether.browsers.brave.enable (pkgs.brave.override chromiumOverrides))
        ++ (lib.optional osConfig.nether.browsers.chromium.enable (
          pkgs.chromium.override chromiumOverrides
        ))
        ++ (lib.optional osConfig.nether.browsers.firefox.enable pkgs.firefox);
    }
  );
}
