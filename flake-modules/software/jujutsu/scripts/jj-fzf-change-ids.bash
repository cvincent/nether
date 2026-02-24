jj log --color=always --ignore-working-copy -T fzf |
  fzf --ansi --height=~50% --delimiter='|' --with-nth='{1}' --accept-nth='{2}' "$@"
