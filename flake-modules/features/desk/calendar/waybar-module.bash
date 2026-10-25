dtf='@longDateTimeFormat@'

export TZ='@timezone@'
export TZDIR='@TZDIR@'

now=$(date +"$dtf")
midnight=$(date +"$dtf" -d 'tomorrow 00:00')

today_event_count=$(
  khal list \
    --day-format '' \
    --notstarted \
    "$now" "$midnight" | wc -l
)

escape_pango() {
  local s
  s=$(cat /dev/stdin)
  s=${s//&/&#38;}
  s=${s//</&#60;}
  s=${s//>/&#62;}
  printf '%s' "$s"
}

week_agenda=$(
  khal list --once \
    --day-format '# {name}, {date}' \
    --format "{start-time}, {duration}: {title}" \
    "$now" "7d" |
    sed 's/^, //' |
    escape_pango |
    sed -E 's/^# (.*)/\n<b>\1<\/b>/' |
    sed -e ':a' -e '$!{N;ba' -e '}' -e 's/^[[:space:]]*//; s/[[:space:]]*$//'
)

jo "text=$today_event_count" "tooltip=$week_agenda"
