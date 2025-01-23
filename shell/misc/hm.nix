{ pkgs, nixpkgs-unstable-latest, ... }:

{
  imports = [
    ./lf/hm.nix
  ];

  home.packages = with pkgs; [
    neofetch
    bitwarden-cli
    nixpkgs-unstable-latest.gh

    (pkgs.writeShellScriptBin "wait-for-port" ''
      echo "Waiting for port $1..."
      while ! nc -z localhost $1; do
        sleep 0.1
      done
    '')
  ];
}
