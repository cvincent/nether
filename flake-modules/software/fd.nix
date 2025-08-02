{ name, mkSoftware, ... }:
mkSoftware name (
  { fd, ... }:
  {
    hm.programs.fd = { inherit (fd) enable package; };
  }
)
