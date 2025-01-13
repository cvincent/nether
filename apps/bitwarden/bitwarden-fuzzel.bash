vault_cache=~/.local/share/bitwarden/vault-cache.json
last_item=~/.local/share/bitwarden/last-fuzzel

start-menu() {
  choice=$(jq -r '.[].name' $vault_cache | fuzzel --prompt='Vault ❯ ' -d)
}

if [[ ! -f "$vault_cache" ]]; then bitwarden-cache-vault; fi

if [[ $1 == '--previous' ]]; then
  choice=$(cat $last_item)
elif [[ -n "$1" ]]; then
  choice=$1
else
  choice=$(jq -r '.[].name' $vault_cache | fuzzel --prompt='Vault ❯ ' -d)
fi

if [[ -z "$choice" ]]; then exit 0; fi

echo "$choice" > $last_item
item=$(jq -a --arg choice "$choice" '.[] | select(.name == $choice)' $vault_cache)
>&2 echo "$item"

declare -A fields
choices=''

# Login fields
fields['Username']=$(echo "$item" | jq -r '.login?.username')
fields['Password']=$(echo "$item" | jq -r '.login?.password')

# Credit card fields
fields['Number']=$(echo "$item" | jq -r '.card?.number')
fields['Expiration']=$(echo "$item" | jq -r '.card?.expMonth + "/" + .card?.expYear')
fields['Expiration Month']=$(echo "$item" | jq -r '.card?.expMonth')
fields['Expiration Year']=$(echo "$item" | jq -r '.card?.expYear')
fields['Brand']=$(echo "$item" | jq -r '.card?.brand')
fields['Name on Card']=$(echo "$item" | jq -r '.card?.cardholderName')

# Login fields
if [[ ${fields['Username']} != 'null' ]]; then choices+=$'Username\n'; fi
if [[ ${fields['Password']} != 'null' ]]; then choices+=$'Password\n'; fi

# Credit card fields
if [[ ${fields['Number']} != 'null' ]]; then choices+=$'Number\n'; fi
if [[ ${fields['Expiration']} != '/' ]]; then choices+=$'Expiration\n'; fi
if [[ ${fields['Expiration Month']} != 'null' ]]; then choices+=$'Expiration Month\n'; fi
if [[ ${fields['Expiration Year']} != 'null' ]]; then choices+=$'Expiration Year\n'; fi
if [[ ${fields['Brand']} != 'null' ]]; then choices+=$'Brand\n'; fi
if [[ ${fields['Name on Card']} != 'null' ]]; then choices+=$'Name on Card\n'; fi
choices+=$'Edit\n'
choices+=$'Delete\n'

field=$(echo "$choices" | fuzzel --placeholder="$choice" --prompt='❯ ' -d)

if [[ -z "$field" ]]; then exit 0; fi

if [[ "$field" == 'Edit' ]]; then
  item_id=$(echo "$item" | jq -r '.id')
  bitwarden-edit $item_id
  exit 0
elif [[ "$field" == 'Delete' ]]; then
  item_id=$(echo "$item" | jq -r '.id')
  confirm=$(echo $'No\nYes\n' | fuzzel --prompt="Delete $choice? ❯ " -d)

  if [[ "$confirm" == 'Yes' ]]; then
    notify-send -i lock -e "Deleted!"
    session=$(bitwarden-ensure-session)
    bw delete item $item_id --session $session
    bitwarden-cache-vault
  else
    >&2 echo 'Cancelled!'
  fi
  exit 0
fi

action=$(echo $'Copy\nShow\n' | fuzzel --placeholder="$choice $field" --prompt='❯ ' -d)

case $action in
  'Copy')
    wl-copy "${fields[$field]}"
    sleep 1
    cliphist delete-query "${fields[$field]}"
    sleep 9
    wl-copy --clear
    ;;

  'Show')
    notify-send -i lock -e "${fields[$field]}"
    ;;
esac
