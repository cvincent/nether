account="${1-}"
status="${2-}"
calendar="${3-}"

calendars() {
  dirs="@calendarsBasePath@/$1/*/displayname"
  for f in $dirs; do
    echo "$(cat "$f")|$(basename "$(dirname "$f")")"
  done
}

if [[ "$calendar" == "" ]]; then
  # NOTE: This probably does not work with accounts other than "personal" which
  # may contain "-" in their true names, since calendar names use "_" due to
  # vdirsyncer.

  calendars "$account" | fzf \
    --delimiter "|" \
    --with-nth="{1}" \
    --accept-nth="{1}"

  exit 0
fi

message=$(cat /dev/stdin)
invite=$(mktemp /tmp/invite.XXX.ics)
trap 'rm "$invite"' EXIT

attachment_number=$(
  mshow -t <(echo "$message") |
    grep -e "text/calendar" -e "application/ics" |
    head -n1 | grep -oE '[0-9]+' | head -n1
)

mshow -O <(echo "$message") "$attachment_number" >"$invite"

khal import --batch -a "$calendar" "$invite"

case "$status" in
"accept")
  aerc :accept -s
  ;;
"maybe")
  aerc :accept-tentative -s
  ;;
esac
