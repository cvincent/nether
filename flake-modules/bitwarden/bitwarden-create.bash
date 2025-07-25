tmp=$(mktemp -q /tmp/item.XXXXXX.json || exit 1)
trap 'rm -f -- "$tmp"' EXIT

json=$(cat ~/.local/share/bitwarden/templates/"$1".json)

case $1 in
  'login')
    if [[ -n "$2" ]]; then
      url=$2
      domain=$(echo "$url" | awk -F/ '{print $3}')
      json=$(echo "$json" | jq --arg domain "$domain" '.name = $domain' | jq --arg url "$url" '.login.uris[0].uri = $url')
    fi
    open_search='USERNAME'
    ;;

  'card')
    open_search='CARDHOLDER_NAME'
    ;;
esac

echo "$json" > "$tmp"
kitty --class=tmp-edit nvim "$tmp" +"/\[$open_search\]" +'norm W'
json=$(cat "$tmp")

if [[ $(echo "$json" | jq empty > /dev/null 2>&1) -eq 0 ]]; then
  >&2 echo 'Valid!'
  confirm=$(echo $'No\nYes\n' | fuzzel --prompt='Save? ❯ ' -d)

  if [[ "$confirm" == 'Yes' ]]; then
    >&2 echo 'Saving!'
    session=$(bitwarden-ensure-session)
    echo "$json" | bw encode | bw create item --session "$session"
    notify-send -i lock -e "Saved!"
    bitwarden-cache-vault
  else
    >&2 echo 'Cancelled!'
  fi
else
  notify-send -i error -e "Invalid!"
fi

rm -f -- "$tmp"
trap - EXIT
exit
