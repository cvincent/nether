template='
  format_short_change_id(change_id) ++ " " ++
  if(self.empty(), empty_commit_marker ++ " ") ++
  description.first_line() ++
  " (" ++ commit_id.short() ++ ") " ++
  self.bookmarks() ++ "|" ++
  change_id.shortest() ++ "\n"
'

jj log --color=always --ignore-working-copy -T "$template" |
  fzf --ansi --height=~50% --delimiter='|' --with-nth='{1}' --accept-nth='{2}' "$@"
