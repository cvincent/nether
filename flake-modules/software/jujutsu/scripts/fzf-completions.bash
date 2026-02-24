line="$1"
shift 1

subcmd=$(echo "$line" | cut -d' ' -f2)

# NOTE: We need a separate script for bookmark completions or to make the
# contextual picker a little smarter, because we often do want change IDs in `jj
# bookmark` commands. And really, we should probably break the jj fzf script up
# and have the contextual completion script call what it needs.

if [[ "$subcmd" == "absorb" ]]; then
  jj diff --ignore-working-copy --name-only |
    fzf --height=75% "$@"
elif [[ "$subcmd" == "bookmark" ]]; then
  jj bookmark list --ignore-working-copy -T 'self.name() ++ "\n"' |
    uniq |
    fzf --height=75% "$@"
else
  template='
    format_short_change_id(change_id) ++ " " ++
    if(self.empty(), empty_commit_marker ++ " ") ++
    description.first_line() ++
    " (" ++ commit_id.short() ++ ") " ++
    self.bookmarks() ++ "|" ++
    change_id.shortest() ++ "\n"
  '

  jj log --color=always --ignore-working-copy -T "$template" |
    fzf --ansi --height=50% --delimiter='|' --with-nth='{1}' --accept-nth='{2}' "$@"
fi
