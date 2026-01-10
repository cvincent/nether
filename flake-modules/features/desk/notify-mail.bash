#! /usr/bin/env nix-shell
#! nix-shell -i bash -p mblaze.out jq.out jo.out

mail_config_file_path=@mailConfigFilePath@
if [[ "${mail_config_file_path:0:1}" == "@" ]]; then
  mail_config_file_path=~/.config/mail-config.json
fi

fifo_path=@fifoPath@
if [[ "${fifo_path:0:1}" == "@" ]]; then
  fifo_path=~/.local/state/.system-notifications
fi

maildir_base_path=$(jq -r '.maildirBasePath' "$mail_config_file_path")

account="${1##"$maildir_base_path/"}"
account="${account%%/new/*}"

folder="${account##*/}"
account="${account%%/*}"

account_display_name=$(
  jq -r --arg account "$account" \
    '.accountConfigs[$account].displayName' \
    "$mail_config_file_path"
)

if [[ -f "$1" ]]; then
  eml="$1"
else
  eml="${1/\/new\//\/cur\/}"
fi

from="$(mhdr -h From "$eml")"
subject="$(mhdr -h Subject "$eml")"

line="$(jo icon=dialog-information "title=$account_display_name / $folder" "body=$subject\n$from")"

echo "$line"
echo "$line" > "$fifo_path"
