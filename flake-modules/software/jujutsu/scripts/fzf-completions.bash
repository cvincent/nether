if [[ $(echo "$1" | cut -d' ' -f2) == "absorb" ]]; then
  jj diff --name-only |
    fzf --height=75%
else
  template='
    format_short_change_id(change_id) ++
    " - " ++
    if(self.empty(), empty_commit_marker ++ " ") ++
    description.first_line() ++
    " (" ++ commit_id.short() ++ ")|" ++
    change_id.shortest() ++ "\n"
  '

  jj log --color=always -T "$template" |
    fzf --ansi --height=50% --delimiter='|' --with-nth='{1}' --accept-nth='{2}'
fi
