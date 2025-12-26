{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    yt-dlp,
    lib,
    pkgInputs,
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
        pkgInputs.nixpkgs-yt-dlp-pot-provider.python313Packages.bgutil-ytdlp-pot-provider
      ];
    };
  }
)
