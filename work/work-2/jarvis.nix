{
  pkgs,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "elco";
  name = "elco";

  src = fetchGit {
    url = "file:///home/cvincent/src/estee/jarvis";
    rev = "aedd2249d2cb0e295650016618bade97666ed6d4";
  };

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl ];

  cargoHash = "sha256-xfLdOVzONa93d/2ouZ2OxAOlUZUS45TRJ+VF3U/vjMM=";
}
