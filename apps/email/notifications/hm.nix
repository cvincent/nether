{ ... }:

let
  watch-maildir = (pkgs.writeShellScriptBin "generate-invoice" (builtins.readFile ./watch-maildir.bash));
in
{
  home.packages = with pkgs; [
    python3
    inotify-tools
    (pkgs.writeShellScriptBin "generate-invoice" (builtins.readFile ./decodemail.py))
    watch-maildir
  ];
}
