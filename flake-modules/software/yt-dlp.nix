{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    yt-dlp,
    lib,
    inputs',
    ...
  }:
  {
    options = lib.getAttrs [ "extraConfig" "settings" ] hmOptions.programs.yt-dlp;

    hm = {
      programs.yt-dlp = {
        inherit (yt-dlp)
          enable
          package
          extraConfig
          settings
          ;
      };

      home.packages = [
        # NOTE: Is it possible to just automatically get this from whatever
        # input yt-dlp itself is coming from? Or perhaps this should be raised
        # to a host option so it can be set there.
        inputs'.nixpkgs-unstable.legacyPackages.python313Packages.bgutil-ytdlp-pot-provider
      ];
    };
  }
)
