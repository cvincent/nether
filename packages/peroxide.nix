# Recovered from https://github.com/NixOS/nixpkgs/blob/22850f79040033b22712d27ad8d95a13e35b0831/pkgs/applications/networking/peroxide/default.nix
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nixosTests,
}:

buildGoModule {
  pname = "peroxide";
  version = "0.5.0";

  src = fetchFromGitHub {
    # NOTE: We're using this fork which is updated to build with newer versions
    # of Go.
    owner = "adamflagg";
    repo = "peroxide";
    rev = "master";
    sha256 = "sha256-+6l82UvnslzB2i6JUFaZStSfakX1HgGV5XLNbluE2qE=";
  };

  vendorHash = "sha256-9R3v3JTOKWa7nd7qKEbwEW4uo8GscsaO79fWGF4Q0rE=";

  postPatch = ''
    # These tests connect to the internet, which does not work in sandboxed
    # builds, so skip these.
    rm pkg/pmapi/dialer_pinning_test.go \
       pkg/pmapi/dialer_proxy_provider_test.go \
       pkg/pmapi/dialer_proxy_test.go
  '';

  passthru.tests.peroxide = nixosTests.peroxide;

  meta = with lib; {
    homepage = "https://github.com/ljanyst/peroxide";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ aidalgol ];
    description = "Unofficial ProtonMail bridge";
    longDescription = ''
      Peroxide is a fork of the official ProtonMail bridge that aims to be
      similar to Hydroxide while reusing as much code from the official bridge
      as possible.
    '';
  };
}
