{
  fetchzip,
  stdenv,
  hash,
  fontName,
  server,
  version ? "unknown",
}:

stdenv.mkDerivation {
  pname = fontName;
  inherit version;

  src = fetchzip {
    url = "${server}/${fontName}.zip";
    inherit hash;
    stripRoot = false;
  };

  installPhase = ''
    install_path=$out/share/fonts/truetype/$fontName
    mkdir -p $install_path
    find -name "*.ttf" -exec mv {} $install_path \;
  '';
}
