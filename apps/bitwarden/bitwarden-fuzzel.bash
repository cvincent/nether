vault_cache=~/.local/share/bitwarden/vault-cache.json

start-menu() {
  choice=$(jq -r '.[].name' $vault_cache | fuzzel -d)
}

if [[ -f "$vault_cache" ]]; then
  start-menu
else
  >&2 echo 'Populating cache...'
  bitwarden-cache-vault
  start-menu
fi

if [[ -z "$choice" ]]; then exit 0; fi

item=$(jq -a --arg choice "$choice" '.[] | select(.name == $choice)' $vault_cache)
>&2 echo "$item"

declare -A fields
choices=''

fields['Username']=$(echo "$item" | jq -a '.login?.username')
fields['Password']=$(echo "$item" | jq -a '.login?.password')

if [[ ${fields['Username']} != 'null' ]]; then choices+=$'Username\n'; fi
if [[ ${fields['Password']} != 'null' ]]; then choices+=$'Password\n'; fi
choices+=$'Edit\n'

choice=$(echo "$choices" | fuzzel -d)
echo ${fields[$choice]}

if [[ -z "$choice" ]]; then exit 0; fi

action=$(echo $'Copy\nShow\n' | fuzzel -d)

case $action in
  pattern 'Copy')
    wl-copy "${fields[$choice]}"
    ;;

  pattern 'Show')
    fuzzel
    notify-send -i lock -e "${fields[$choice]}"
    ;;
esac
