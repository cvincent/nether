#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq.out

IFS=$'\n'

account=@account@
if [[ "${account:0:1}" == "@" ]]; then
  account=personal
fi

mail_config_file_path=@mailConfigFilePath@
if [[ "${mail_config_file_path:0:1}" == "@" ]]; then
  mail_config_file_path=~/.config/mail-config.json
fi

cache=$(
  jq -r --arg account "$account" \
    '.accountConfigs[$account].totalCountCachePath' \
    "$mail_config_file_path"
)

if [[ -f "$cache" ]]; then
  cat "$cache"
  exit 0
fi

mapfile -d '' folders < <(
  jq --raw-output0 --arg account "$account" \
    '.accountConfigs[$account].totalCountFolders[]' \
    "$mail_config_file_path"
)

total=$(
  count-unread-email |
    jq -j --arg account "$account" \
      '
        .[$account] | to_entries |
          map(select(.key | index($ARGS.positional[])).value) | add
      ' \
      --args "${folders[@]}"
)

mkdir -p "$(dirname "$cache")"
echo -n "$total" > "$cache"
echo -n "$total"
