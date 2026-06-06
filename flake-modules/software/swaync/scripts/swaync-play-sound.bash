sound_name="${SWAYNC_SOUND_NAME-}"
sound_file="${SWAYNC_SOUND_FILE-}"
urgency="${SWAYNC_URGENCY}"
cache_dir="$XDG_CACHE_HOME/swaync-play-sound"
file_for_id="$cache_dir/${SWAYNC_ID}"

mkdir -p "$cache_dir"

if [[ ! -f "$file_for_id" ]]; then
  touch "$file_for_id"
  if [[ "$(swaync-client --get-dnd)" == "false" || "$urgency" == "Critical" ]]; then
    if [[ "$sound_name" != "" && "$sound_name" != "(null)" ]]; then
      canberra-gtk-play -i "$sound_name" -V 1
    elif [[ "$sound_file" != "" && "$sound_file" != "(null)" ]]; then
      canberra-gtk-play -f "$sound_file" -V 1
    fi
  fi
fi

find "$cache_dir" -type f -mmin +30 -delete
