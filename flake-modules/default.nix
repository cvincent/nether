{ mkFeature, ... }:
{ flake-parts-lib, ... }:
{
  imports = [
    (flake-parts-lib.importApply ./features { inherit mkFeature; })
    ./scripts
    ./software
  ];
}
