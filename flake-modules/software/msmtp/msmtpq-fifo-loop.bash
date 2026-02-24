#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq.out msmtp.out coreutils.out

# Usage: Pipe a line of JSON into the FIFO path. It should be structured like
# so:

# {
#   "subject": "Hello",
#   "body": "World",
#   "from": "First Last email@example.com",
#   "to": [
#     "--to", "John Doe john@example.com",
#     "--to", "Jane Doe jane@example.com"
#   ],
#   "account": "personal",
#   "attach": "/tmp/will-be-deleted.txt"
# }

# The attachment will be deleted so ensure this is a path to a temporary copy of
# the file to be sent! Currently does not support sending emails without
# attachments.

msmtp_config_path=@msmtpConfigPath@
msmtpq_fifo_path=@msmtpqFifoPath@

if [[ ! -p "$msmtpq_fifo_path" ]]; then
  mkfifo "$msmtpq_fifo_path"
fi

echo "Reading $msmtpq_fifo_path..."
while true; do
  while read -r line <"$msmtpq_fifo_path"; do
    echo "$line"

    body=$(echo "$line" | jq -r .body)

    declare msg
    declare -A "msg=($(echo "$line" | jq 'delpaths([["body"], ["to"]])' | json_to_assoc))"
    declare to
    declare -a "to=($(echo "$line" | jq -r '.to | @sh'))"

    echo "$body" |
      # TODO: We can probably ditch mime-email in favor of mblaze's mmime or
      # makemime from maildrop or busybox
      mime-email --subject "${msg[subject]}" \
        --attach "${msg[attach]}" \
        --from "${msg[from]}" \
        "${to[@]:?}" |
      msmtpq --account "${msg[account]}" \
        -C "$msmtp_config_path" \
        --read-recipients --read-envelope-from

    rm "${msg[attach]}"
  done
done
