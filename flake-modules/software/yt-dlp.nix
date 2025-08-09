{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    yt-dlp,
    lib,
    ...
  }:
  {
    options = lib.getAttrs [ "extraConfig" "settings" ] hmOptions.programs.yt-dlp;

    hm.programs.yt-dlp = {
      inherit (yt-dlp)
        enable
        package
        extraConfig
        settings
        ;
    };
  }
)
