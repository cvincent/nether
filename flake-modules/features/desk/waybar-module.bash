#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq.out jo.out

IFS=$'\n'

mail_config_file_path=@mailConfigFilePath@
if [[ "${mail_config_file_path:0:1}" == "@" ]]; then
  mail_config_file_path=~/.config/mail-config.json
fi

notify_folders_by_account=$(
  jq '
      .accountConfigs |
      with_entries({
        key, value: .value.folders |
        with_entries(select(.value.notifyLevel == "notify")) | keys
      })
    ' "$mail_config_file_path"
)

total_count_folders_by_account=$(
  jq '.accountConfigs | with_entries({key, value: .value.totalCountFolders})' \
    "$mail_config_file_path"
)

mapfile -d '' accounts < <(
  jq --raw-output0 '.displayOrder[]' "$mail_config_file_path"
)

unread_mail_by_account=$(count-unread-email)

function get-count {
  mapfile -d '' ref_names < <(
    jq --raw-output0 --arg account "$1" \
      '.[$account][]' <(echo "$2")
  )

  local count
  count=$(
    echo "$unread_mail_by_account" |
      jq -r --arg account "$1" \
        '
          .[$account] |
          with_entries(select(.key | index($ARGS.positional[]))) | add
        ' \
        --args "${ref_names[@]}"
  )

  echo "$count"
}

declare -A tooltip
total_count=
notify_count=

for account in "${accounts[@]}"; do
  count=$(get-count "$account" "$total_count_folders_by_account")

  total_count=$(("$total_count" + "$count"))

  count=$(get-count "$account" "$notify_folders_by_account")
  notify_count=$(("$notify_count" + "$count"))

  count=$(
    echo "$unread_mail_by_account" |
      jq -r --arg account "$account" '.[$account] | add'
  )

  if [[ "$count" -gt 0 ]]; then
    display_name=$(
      jq -r --arg account "$account" \
        '.accountConfigs.[$account].displayName' "$mail_config_file_path"
    )

    tooltip["$account"]="$display_name"$'\n'

    mapfile -d '' folders < <(
      echo "$total_count_folders_by_account" |
        jq --raw-output0 --arg account "$account" '.[$account][]'
    )

    display_names=$(
      jq --arg account "$account" \
        '.accountConfigs.[$account].folders | with_entries({key, value: .value.localName})' \
        "$mail_config_file_path"
    )

    for folder in "${folders[@]}"; do
      display_name=$(
        echo "$display_names" |
          jq -r --arg folder "$folder" '.[$folder]'
      )

      folder_count=$(
        echo "$unread_mail_by_account" |
          jq -r --arg account "$account" --arg folder "$folder" \
            '.[$account][$folder]'
      )

      if [[ "$folder_count" -gt 0 ]]; then
        tooltip["$account"]+="$display_name: $folder_count"$'\n'
      fi
    done
  fi
done

paste_args=()
for col in "${tooltip[@]}"; do
  paste_args+=("<(echo '$col')")
done

if [[ -z "${paste_args[*]}" ]]; then
  tooltip_text=""
else
  # shellcheck disable=SC2145
  # shellcheck disable=SC2294
  tooltip_text=$(eval "paste ${paste_args[@]}" | column -t -s $'\t')
fi

if [[ $notify_count -lt $total_count ]]; then
  text="$notify_count*"
else
  text="$notify_count"
fi

jo "text=$text" "tooltip=$tooltip_text"
