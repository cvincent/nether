{ pkgs, myHomeDir, utils, ... }:

{
  home.packages = with pkgs; [
    isync # Sync IMAP locally
    pandoc # To view text/html emails
    msmtp # Send email from command line

    (writeShellScriptBin "file-email" ''
      # cat /dev/stdin > test.out

      address=$(cat /dev/stdin | grep "^From:" -A1 | sed -z 's/From:.*<\(.\+\)>/\1/; s/\r//g' | head -n1)

      choices="Important\nFeed\nPaper Trail\nScreened Out\n"
      choice=$(echo -e $choices | fuzzel -p "File $address: " --dmenu)
      dir=""

      case $choice in
      "Important")
        dir="important";;
      "Feed")
        dir="feed";;
      "Paper Trail")
        dir="paper_trail";;
      "Screened Out")
        dir="screened_out";;
      esac

      if [ $dir ]; then
        echo $address >> /backup/imapfilter/$dir/by_address
        notify-send -i dialog-information -t 5000 -e "Filed $address to $choice."
      fi
    '')
  ];

  programs.aerc.enable = true;
  sops.secrets."aerc_accounts" = { path = "${myHomeDir}/.config/aerc/accounts.conf"; };

  sops.secrets."mbsyncrc" = { path = "${myHomeDir}/.mbsyncrc"; };

  home.file = {
    "./.config/aerc/aerc.conf".source = utils.directSymlink "apps/email/aerc/aerc.conf";
    "./.config/aerc/binds.conf".source = utils.directSymlink "apps/email/aerc/binds.conf";
    "./.config/aerc/stylesets".source = utils.directSymlink "apps/email/aerc/stylesets";
  };
}
