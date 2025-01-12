vault_cache=~/.local/share/bitwarden/vault-cache.json
session=$(bitwarden-ensure-session)
bw list items --session "$session" > $vault_cache
