{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    mpv,
    lib,
    ...
  }:
  {
    options = lib.getAttrs [ "config" "scripts" "scriptOpts" ] hmOptions.programs.mpv;

    hm.programs.mpv = {
      inherit (mpv)
        enable
        package
        config
        scripts
        scriptOpts
        ;
    };
  }
)
