jj bookmark list --color=always --ignore-working-copy -T 'self.name() ++ "\n"' |
  uniq |
  fzf --ansi --height=~50% "$@"
