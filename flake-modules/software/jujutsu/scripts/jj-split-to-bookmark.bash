split="$1"
bookmark="$2"
shift 2

if [[ "$split" == "split" ]]; then
  jj split -A "$bookmark" "$@"
  jj bookmark move "$bookmark" --to "${bookmark}+"
elif [[ "$split" == "stack_split" ]]; then
  cmd_result=$(jj stack_split "$@" 2>&1)
  new_change_id=$(echo "$cmd_result" | grep "Selected changes : " | cut -d' ' -f4)
  jj bookmark create "$bookmark" -r "$new_change_id"
fi
