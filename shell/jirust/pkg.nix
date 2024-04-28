{ lib, pkgs, rustPlatform, ... }:

rustPlatform.buildRustPackage rec {
  pname = "jirust";
  version = "1.1.7";

  src = fetchTarball {
    url = "https://github.com/Code-Militia/jirust/archive/refs/tags/1.1.7.tar.gz";
    sha256 = "";
  };

  cargoSha256 = "";
}
