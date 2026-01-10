#! /usr/bin/env nix-shell
#! nix-shell -i bash -p mblaze.out jo.out jq.out

IFS=$'\n'

mail_config_file_path=@mailConfigFilePath@
if [[ "${mail_config_file_path:0:1}" == "@" ]]; then
  mail_config_file_path=~/.config/mail-config.json
fi

maildir_base_path=$(jq -r '.maildirBasePath' "$mail_config_file_path")

mapfile -d '' accounts < <(
  jq --raw-output0 \
    '.accountConfigs | keys | .[]' \
    "$mail_config_file_path"
)

accounts_obj=()

for account in "${accounts[@]}"; do
  mapfile -d '' folders < <(mdirs -0 "$maildir_base_path/$account")

  account_obj=()

  for folder in "${folders[@]}"; do
    imapPath=${folder#"$maildir_base_path/$account/"}

    ref_name=$(
      jq -r --arg account "$account" --arg imapPath "$imapPath" \
        '
          .accountConfigs[$account].folders |
          map(select(.imapPath == $imapPath).refName) | .[]
        ' \
        "$mail_config_file_path"
    )

    if [[ -n "$ref_name" ]]; then
      account_obj+=("$ref_name=$(mlist -s "$folder" | wc -l)")
    fi
  done

  accounts_obj+=("$account=$(jo "${account_obj[@]}")")
done

jo "${accounts_obj[@]}"
