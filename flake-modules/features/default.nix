{ mkFeature, ... }:
{ flake-parts-lib, lib, ... }:
{
  imports =
    (
      ./.
      |> builtins.readDir
      |> (lib.attrsets.filterAttrs (_k: v: v == "regular"))
      |> lib.attrsets.attrNames
      |> (lib.lists.remove "default.nix")
      |> (lib.lists.map (name: lib.strings.removeSuffix ".nix" name))
      |> (lib.map (
        mod:
        (flake-parts-lib.importApply ./${mod}.nix {
          name = mod;
          inherit mkFeature;
        })
      ))
    )
    ++ [ (import ./windows-vm { name = "windows-vm"; }) ];
}
