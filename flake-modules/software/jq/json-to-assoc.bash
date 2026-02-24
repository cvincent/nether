#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq.out

jq -r 'to_entries[] | "[\(.key|@sh)]=\(.value|@sh)"'
