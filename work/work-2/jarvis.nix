{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "elco";
  version = "2024.10.15-1";

  src = fetchFromGitHub {
    owner = "elc-online";
    repo = pname;
    rev = version;
    hash = "";
  };

  cargoHash = "";

  meta = with lib; {
    description = "Elco tool";
    homepage = "https://github.com/elc-online/jarvis";
    license = licenses.unlicense;
    maintainers = [ ];
  };
}
