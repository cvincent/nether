#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq.out libnotify.out dbus.out coreutils.out

fifo_path=@fifoPath@
if [[ "${fifo_path:0:1}" == "@" ]]; then
  fifo_path=~/.local/state/.system-notifications
fi

if [[ ! -p "$fifo_path" ]]; then
  mkfifo "$fifo_path"
fi

while true; do
  while read -r line < "$fifo_path"; do
    echo "$line"
    icon=$(echo "$line" | jq -r '.icon')
    title=$(echo "$line" | jq -r '.title')
    body=$(echo "$line" | jq -r '.body')

    notify-send -i "$icon" "$title" "$body"
  done
done
