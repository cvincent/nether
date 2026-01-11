{
  name,
  mkFeature,
  mkSoftwareChoice,
  ...
}:
mkFeature name (
  {
    nether,
    browsers,
    lib,
    ...
  }:
  (
    (mkSoftwareChoice
      {
        inherit name;
        namespace = "toplevel";
        thisConfig = browsers;
        enableDefault = true;
      }
      {
        brave.config.commandLineArgs = browsers.chromiumArgs;
        chromium.config.commandLineArgs = browsers.chromiumArgs;
        firefox = { };
        qutebrowser = { };
      }
    )
    |> lib.recursiveUpdate {
      description = "Browsers for the World Wide Web";

      options = {
        chromiumArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "--enable-features=VaapiVideoEncoder"
            "--ignore-gpu-blocklist"
            "--enable-zero-copy"
          ];
        };
      };
    }
  )
)
