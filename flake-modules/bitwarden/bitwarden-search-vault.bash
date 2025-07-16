vault_cache=~/.local/share/bitwarden/vault-cache.json
query=$1

search() {
  >&2 echo "Searching for $query..."
  jq --arg query "$query" '[.[] | select((.name | ascii_downcase | contains($query | ascii_downcase)) or (.login.uris.[]?.uri | ascii_downcase | contains($query | ascii_downcase)))]' $vault_cache
}

if [[ -f "$vault_cache" ]]; then
  >&2 echo 'Searching cache...'
  search
else
  >&2 echo 'Populating cache...'
  bitwarden-cache-vault
  search
fi
