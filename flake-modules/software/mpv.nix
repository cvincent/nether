{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    mpv,
    lib,
    ...
  }:
  {
    options = lib.getAttrs [ "config" "bindings" "scripts" "scriptOpts" ] hmOptions.programs.mpv;

    hm.programs.mpv = {
      inherit (mpv)
        enable
        package
        config
        bindings
        scripts
        scriptOpts
        ;
    };
  }
)
