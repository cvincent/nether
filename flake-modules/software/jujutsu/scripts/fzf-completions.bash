line="$1"
shift 1

subcmd=$(echo "$line" | cut -d' ' -f2)
last_arg=$(echo "$line" | awk -F' ' '{print $NF}')

complete_bookmarks=1

case "$last_arg" in
bookmark | --bookmark | -b) ;;
-*) complete_bookmarks=0 ;;
*) complete_bookmarks=0 ;;
esac

if [[ "$subcmd" == "absorb" ]]; then
  jj-fzf-changed-files "$@"
elif [[ "$subcmd" == "bookmark" && "$complete_bookmarks" == 1 ]]; then
  jj-fzf-bookmarks "$@"
elif [[ "$subcmd" == "git" && "$complete_bookmarks" == 1 ]]; then
  jj-fzf-bookmarks "$@"
else
  jj-fzf-change-ids "$@"
fi
