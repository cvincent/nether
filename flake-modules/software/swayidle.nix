{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    swayidle,
    lib,
    ...
  }:
  {
    options = lib.getAttrs [ "events" "timeouts" ] hmOptions.services.swayidle;

    hm.services.swayidle = {
      inherit (swayidle)
        enable
        package
        events
        timeouts
        ;
    };
  }
)
