{ lib
, stdenv
, fetchzip
, buildFHSEnv
}:

let
  version = "22.1.22";
  name = "cockroachdb";

  # For several reasons building cockroach from source has become
  # nearly impossible. See https://github.com/NixOS/nixpkgs/pull/152626
  # Therefore we use the pre-build release binary and wrap it with buildFHSUserEnv to
  # work on nix.
  # You can generate the hashes with
  # nix flake prefetch <url>
  srcs = {
    aarch64-linux = fetchzip {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.linux-arm64.tgz";
      hash = "";
    };
    x86_64-linux = fetchzip {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.linux-amd64.tgz";
      hash = "sha256-sAiUKeWaeW6knegkW5a9w2oqtWhpYf5rylBl5zB5gy4=";
    };
  };
  src = srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

in
buildFHSEnv {
  inherit name;

  runScript = "${src}/cockroach";

  meta = with lib; {
    homepage = "https://www.cockroachlabs.com";
    description = "A scalable, survivable, strongly-consistent SQL database";
    license = licenses.bsl11;
    platforms = [ "aarch64-linux" "x86_64-linux" ];
    maintainers = with maintainers; [ rushmorem thoughtpolice neosimsim ];
  };
}
