#! /usr/bin/env nix-shell
#! nix-shell -i bash -p aerc.out libnotify.out mblaze.out gnugrep.out

IFS=$'\n\t'

account=@account@
if [[ "${account:0:1}" == "@" ]]; then
  account=personal
fi

mail_config_file_path=@mailConfigFilePath@
if [[ "${mail_config_file_path:0:1}" == "@" ]]; then
  mail_config_file_path=~/.config/mail-config.json
fi

filters_base_path=$(jq -r '.filtersBasePath' "$mail_config_file_path")

choice="$1"
ref_name=''

ref_name=$(
  jq -r --arg account "$account" --arg localName "$choice" \
    '
      .accountConfigs[$account].folders |
        map(select(.localName == $localName)).[].refName
    ' \
    "$mail_config_file_path"
)

if [ "$ref_name" ]; then
  from_address="$(mhdr -h From -)"

  if [[ "$from_address" =~ \<([^>]+)\> ]]; then
    from_address="${BASH_REMATCH[1]}"
  else
    from_address+="$from_address"
  fi

  mapfile -d '' all_ref_names < <(
    jq --raw-output0 --arg account "$account" \
      '.accountConfigs[$account].folders[].refName' \
      "$mail_config_file_path"
  )

  # First remove this address from all filters
  for r in "${all_ref_names[@]}"; do
    filter_file="${filters_base_path}/${account}/${r}/by_address"

    if [[ -f "$filter_file" ]]; then
      tmp="$filter_file".tmp
      grep -xFv -- "$from_address" "$filter_file" > "$tmp" && mv "$tmp" "$filter_file"
    fi
  done

  # Then add the address to the appropriate filter, keeping it sorted
  filter_file="${filters_base_path}/${account}/${ref_name}/by_address"
  echo "$from_address" >> "$filter_file"
  sort "$filter_file" > "$filter_file".tmp && mv "$filter_file".tmp "$filter_file"

  notify-send -i dialog-information -t 5000 -e "Filed $from_address to $choice."

  mapfile -d '' total_count_folders < <(
    jq --raw-output0 --arg account "$account" \
      '.accountConfigs[$account].totalCountFolders[]' \
      "$mail_config_file_path"
  )

  mark_read="true"

  for r in "${total_count_folders[@]}"; do
    if [[ "$r" == "$ref_name" ]]; then
      mark_read="false"
      break
    fi
  done

  if [[ "$mark_read" == "true" ]]; then
    aerc :remark
    aerc :read
  fi

  aerc :remark
  aerc :mv "$choice"
fi
