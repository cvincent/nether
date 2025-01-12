client_id=$(cat ~/.local/share/bitwarden/client_id)
client_secret=$(cat ~/.local/share/bitwarden/client_secret)
bw_password=$(cat ~/.local/share/bitwarden/password)

session_file=~/.local/share/bitwarden/session

function new-session() {
  >&2 echo "Starting new session..."
  bw logout > /dev/null
  BW_CLIENTID=$client_id BW_CLIENTSECRET=$client_secret bw login --apikey > /dev/null
  session=$(bw unlock --raw $bw_password) > /dev/null
  echo $session > $session_file
  echo $session
}

if [[ -f "$session_file" ]]; then
  >&2 echo "Using existing session."
  session=$(cat ~/.local/share/bitwarden/session)
else
  new-session
fi

echo $session
