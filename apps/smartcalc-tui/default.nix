{ pkgs, ... }:

{
  home.packages = [
    (pkgs.callPackage ./pkg.nix {})

    # smartcalc crashes if it's started immediately with kitty for the
    # scratchpad, and you can't just pass 'sleep 1 && smartcalc' directly to
    # kitty, hence this script
    (pkgs.writeShellScriptBin "smartcalc-slow-start" ''
      sleep 1
      smartcalc
    '')
  ];
}
