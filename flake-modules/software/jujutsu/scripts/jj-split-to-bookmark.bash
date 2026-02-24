bookmark="$1"
shift

jj split -A "$bookmark" "$@"
jj bookmark move "$bookmark" --to "${bookmark}+"
