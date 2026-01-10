#! /usr/bin/env nix-shell
#! nix-shell -i bash -p coreutils.out jq.out

input=''${1:-}

if [[ -z $input ]] || [[ $input == "-" ]]; then
  input=$(mktemp)
  trap 'rm -f $input' EXIT
  cat /dev/stdin > "$input"
fi

echo "$input"

echo "" | fzf \
  --phony \
  --preview-window='up:99%' \
  --print-query \
  --preview "jq --color-output -r {q} $input"
