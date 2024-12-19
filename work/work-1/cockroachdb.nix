{
  lib,
  stdenv,
  fetchzip,
  buildFHSEnv,
  version,
  version-hash,
}:

let
  name = "cockroachdb";

  # For several reasons building cockroach from source has become
  # nearly impossible. See https://github.com/NixOS/nixpkgs/pull/152626
  # Therefore we use the pre-build release binary and wrap it with buildFHSUserEnv to
  # work on nix.
  # You can generate the hashes with
  # nix flake prefetch <url>
  srcs = {
    x86_64-linux = fetchzip {
      url = "https://binaries.cockroachdb.com/cockroach-v${version}.linux-amd64.tgz";
      hash = version-hash;
    };
  };
  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

in
buildFHSEnv {
  inherit name;

  runScript = "${src}/cockroach";

  meta = with lib; {
    homepage = "https://www.cockroachlabs.com";
    description = "A scalable, survivable, strongly-consistent SQL database";
    license = licenses.bsl11;
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    maintainers = with maintainers; [
      rushmorem
      thoughtpolice
      neosimsim
    ];
  };
}
