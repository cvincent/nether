templates=$(find ~/.local/share/bitwarden/templates/ -type f | xargs basename -s .json | sed 's/.*/\u&/')
type=$(echo "$templates" | fuzzel --prompt="Create ❯ " -d)

if [[ -z "$type" ]]; then exit 0; fi

type=$(echo "$type" | tr '[:upper:]' '[:lower:]')
bitwarden-create $type
