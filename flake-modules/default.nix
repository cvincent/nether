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
  # TODO: Decide on a consistent way to handle subdirectories; with NeoVim we
  # have editors.nix pulling it in
  imports = (lib.map (mod: (import ./${mod}.nix { name = mod; })) modules) ++ [
    (import ./bitwarden { name = "bitwarden"; })
    (import ./lf { name = "lf"; })
    (import ./tmux { name = "tmux"; })
    (import ./windows-vm { name = "windows-vm"; })
    ./scripts
  ];
}
