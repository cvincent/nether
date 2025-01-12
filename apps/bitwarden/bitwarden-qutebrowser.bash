if [[ -n "$QUTE_URL" ]]; then
  url="$QUTE_URL"
else
  url="$1"
fi

domain=$(echo "$url" | awk -F/ '{print $3}')
>&2 echo "URL: $url"
>&2 echo "DOMAIN: $domain"

result=$(bitwarden-search-vault "$domain")
num_results=$(echo $result | jq length)

case $num_results in
  1)
    >&2 echo 'Exactly one result!'
    item=$result
    ;;

  0)
    >&2 echo 'No results!'
    notify-send "No results for $domain..." -i lock
    ;;

  *)
    >&2 echo 'Multiple results...'
    choice=$(echo $result | jq -r '.[].name' | fuzzel -d | tr -cd '[:alnum:][:punct:]')
    if [[ -n "$choice" ]]; then
      >&2 echo "Chose $choice!"
      item=$(echo $result | jq -a --arg choice '.[]|select(.name=="$choice")')
    fi
    ;;
esac

if [[ -n "$item" ]]; then
  username=$(echo $item | jq -r '.[0].login.username')
  password=$(echo $item | jq -r '.[0].login.password')
  totp=$(echo $item | jq -r '.[0].login.totp')

  >&2 echo "Username: $username"
  >&2 echo "Password: $password"
  >&2 echo "TOTP: $totp"

  if [[ -n "$QUTE_FIFO" ]]; then
    >&2 echo 'Writing autofill to Qutebrowser...'
    echo "fake-key $username" >> "$QUTE_FIFO"
    echo "fake-key <tab>" >> "$QUTE_FIFO"
    echo "fake-key $password" >> "$QUTE_FIFO"
  else
    echo $result
  fi
else
  >&2 echo "Nothing chosen!"
fi
