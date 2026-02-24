attr_path="${1-}"
script=${attr_path##*.}
hostname=@hostname@

shift

if [[ "$attr_path" == "" ]]; then
  echo "Must provide an attr path, relative to #nixosConfigurations.$hostname.config."
  exit 1
fi

nix shell --ignore-environment \
  --keep DISPLAY \
  --keep DBUS_SESSION_BUS_ADDRESS \
  "@dotfilesDirectory@#nixosConfigurations.$hostname.config.$attr_path" \
  -c "$script" "$@"
