line="$1"
shift 1

subcmd=$(echo "$line" | cut -d' ' -f2)

# NOTE: We need a separate script for bookmark completions or to make the
# contextual picker a little smarter, because we often do want change IDs in `jj
# bookmark` commands.

if [[ "$subcmd" == "absorb" ]]; then
  jj-fzf-changed-files "$@"
elif [[ "$subcmd" == "bookmark" ]]; then
  jj-fzf-bookmarks "$@"
else
  jj-fzf-change-ids "$@"
fi
