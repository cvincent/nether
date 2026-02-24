servername="$1"
shift

nvr --servername "$servername" \
  -cc ':RemoteFloatingEdit' \
  --remote-wait "$@"
