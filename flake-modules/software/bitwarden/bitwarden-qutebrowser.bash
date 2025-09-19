if [[ -n "$QUTE_URL" ]]; then
  url="$QUTE_URL"
else
  url="$1"
fi

domain=$(echo "$url" | awk -F/ '{print $3}')
>&2 echo "URL: $url"
>&2 echo "DOMAIN: $domain"

result=$(bitwarden-search-vault "$domain")
num_results=$(echo "$result" | jq length)

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
    choice=$(echo "$result" | jq -r '.[] | [.name, " (", .login.username, ")"] | join("")' | fuzzel --prompt='Vault ❯ ' -d -w60 --index)
    if [[ -n "$choice" ]]; then
      >&2 echo "Chose $choice!"
      item=$(echo "$result" | jq -a --argjson choice "$choice" '.[$choice]')
      echo "$item"
    fi
    ;;
esac

if [[ -n "$item" ]]; then
  username=$(echo "$item" | jq -r '.login.username')
  password=$(echo "$item" | jq -r '.login.password')
  totp=$(echo "$item" | jq -r '.login.totp')

  >&2 echo "Username: $username"
  >&2 echo "Password: $password"
  >&2 echo "TOTP: $totp"

  if [[ -n "$QUTE_FIFO" ]]; then
    >&2 echo 'Writing autofill to Qutebrowser...'
    {
      echo "fake-key $username"
      echo "fake-key <tab>"
      echo "fake-key $password"
    } >> "$QUTE_FIFO"
  else
    echo "$result"
  fi
else
  >&2 echo "Nothing chosen!"
fi
