{ name, mkSoftware, ... }:
mkSoftware name (
  { wlr-randr, ... }:
  {
    hm.home.packages = [ wlr-randr.package ];
  }
)
