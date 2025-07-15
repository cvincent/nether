{ lib, ... }:
let
  modules =
    ./.
    |> builtins.readDir
    |> (lib.attrsets.filterAttrs (_k: v: v == "regular"))
    |> lib.attrsets.attrNames
    |> (lib.lists.remove "default.nix")
    |> (lib.lists.map (name: lib.strings.removeSuffix ".nix" name));
in
{
  imports = lib.map (mod: (import ./${mod}.nix { name = mod; })) modules;
}
