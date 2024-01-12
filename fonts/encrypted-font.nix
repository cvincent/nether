{ runCommand, sops, unzip, name, key }:

runCommand name {
  inherit key;
  src = ../sops/secrets/fonts/${name}.zip.enc;
  buildInputs = [ sops unzip ];
} ''
  SOPS_AGE_KEY_FILE=$key sops -d $src > $name.zip
  unzip $name.zip

  install_path=$out/share/fonts/truetype/$name
  mkdir -p $install_path

  find -name "*.ttf" -exec mv {} $install_path \;
''
