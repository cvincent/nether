{
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  file,
  gnused,
  lib,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mime-email";
  version = "2025-12-21"; # Using latest commit date

  src = fetchFromGitHub {
    owner = "kazune";
    repo = "mime-email";
    rev = "82906da0ba1b80f833c2e61bee1e38e88c7ae630";
    hash = "sha256-XM0aeweraouuFr4A+jnXtX7bCW5SKNl0mtoOxir1OEQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/mime-email $out/bin/
    chmod +x $out/bin/mime-email

    # Patch the script to be a bit more permissive; --to and --from are
    # redundant when we're just piping this output into msmtp.
    sed -i '228,239d' $out/bin/mime-email

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/mime-email \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          file
          gnused
        ]
      }
  '';

  meta = with lib; {
    description = "generate a MIME-formatted email message";
    homepage = "https://github.com/kazune/mime-email";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "mime-email";
  };
})
