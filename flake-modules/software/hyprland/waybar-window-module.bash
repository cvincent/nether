#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq.out jo.out

monitor=$(
  hyprctl monitors -j |
    jq --arg output "$WAYBAR_OUTPUT_NAME" \
      'map(select(.name == $output))[] | {id,name,activeWorkspace,focused}'
)

focused=$(echo "$monitor" | jq '.focused')
workspaceId=$(echo "$monitor" | jq '.activeWorkspace.id')

windowTitle=$(
  hyprctl workspaces -j |
    jq -r --arg workspaceId "$workspaceId" \
      'map(select(.id == ($workspaceId | tonumber)))[].lastwindowtitle'
)

class=
if [[ $focused == 'true' ]]; then
  class='focused'
fi

jo "text=$windowTitle" "tooltip=$WAYBAR_OUTPUT_NAME" "class=$class"
