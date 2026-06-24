file="$1"
shift

jj log -r "files($file)" --color=always --ignore-working-copy -T fzf |
  grep -v "(elided revisions)" |
  fzf --ansi --height=~50% --delimiter='|' --with-nth='{1}' --accept-nth='{2}' "$@"
