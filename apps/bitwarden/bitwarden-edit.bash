item_id="$1"
vault_cache=~/.local/share/bitwarden/vault-cache.json

if [[ ! -f "$vault_cache" ]]; then
  >&2 echo 'Populating cache...'
  bitwarden-cache-vault
fi

item=$(jq -a --arg item_id "$item_id" '.[] | select(.id == $item_id)' $vault_cache)

tmp=$(mktemp -q /tmp/item.XXXXXX.json || exit 1)
trap 'rm -f -- "$tmp"' EXIT

echo "$item" > $tmp
kitty --class=tmp-edit nvim $tmp
changed=$(cat $tmp)

echo "$changed" | jq empty > /dev/null 2>&1

if [[ $? -eq 0 ]]; then
  >&2 echo 'Valid!'
  confirm=$(echo $'No\nYes\n' | fuzzel --prompt='Save? ❯ ' -d)

  if [[ "$confirm" == 'Yes' ]]; then
    notify-send -i lock -e "Edit saved!"
    session=$(bitwarden-ensure-session)
    echo "$changed" | bw encode | bw edit item $item_id --session $session
    bitwarden-cache-vault
  else
    >&2 echo 'Cancelled!'
  fi
else
  notify-send -i error -e "Invalid edit!"
fi

rm -f -- "$tmp"
trap - EXIT
exit
