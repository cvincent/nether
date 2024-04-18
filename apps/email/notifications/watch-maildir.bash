#!/usr/bin/env bash

inotifywait -e move --monitor -r ~/mail | while read line
# cat ~/maildir-inotify | while read line
do
  dir=${line%' MOVED_'*}

  cmd_filename=${line#$dir}
  read -r cmd filename <<< $cmd_filename

  dir_basename=$(basename "$dir")
  email="$dir$filename"

  if [ $cmd == 'MOVED_TO' ] && [ $dir_basename == 'new' ] && [ -a "$email" ]; then
    from=$(./decodemail.py From: "$email")
    from=${from#'From: '*}

    subject=$(./decodemail.py Subject: "$email")
    subject=${subject#'Subject: '*}

    folder=$(dirname "$dir")
    folder_name=$(basename "$folder")
    folder=${folder#$HOME/mail*}

    case "$folder" in
      "/personal/Folders/Feed"|"/personal/Folders/Important"|"personal/Folders/Dev")
        notify-send -i dialog-information "$folder_name: $subject" "From $from"
        ;;
      "/elc/INBOX")
        notify-send -i dialog-information "ELC: $subject" "From $from"
        ;;
      *)
        ;;
    esac
  fi
done
