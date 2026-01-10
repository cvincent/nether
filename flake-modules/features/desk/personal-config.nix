fullName: rec {
  primary = true;

  name = "personal";
  displayName = "Personal";

  signature = ''
    Thanks,

    ${fullName}
    https://github.com/cvincent
  '';

  imap = {
    host = "127.0.0.1";
    port = 1143;
    tls.enable = false;
    imapFilterSSL = null;
  };

  smtp = {
    scheme = "smtp+insecure";
    host = "127.0.0.1";
    port = 1025;

    copyTo = true;

    # NOTE: ProtonMail generally has shit handling of multipart messages.
    # Seemingly it destroys the text part on incoming messages, and also
    # destroys the HTML part on outgoing messages. Furthermore, ProtonMail
    # strips out format=flowed. We really ought to just switch E2EE for
    # email is an impossible farce anyways.
    htmlMultipart = false;
  };

  excludeFolders = [ "All Mail" ];

  foldersPrefix = "Folders";

  # notifyLevel
  # null/unset (default) - no notification, don't include in any counts
  # "totalCount" - include in total count
  # "notify" - desktop notification, and include in total important count

  folderLayout = [
    rec {
      refName = "drafts";
      localName = "Drafts";
      imapPath = localName;
    }

    rec {
      refName = "sent";
      localName = "Sent";
      imapPath = localName;
    }

    rec {
      refName = "unscreened";
      localName = "Unscreened";
      imapPath = "${foldersPrefix}/${localName}";
      notifyLevel = "totalCount";
    }

    rec {
      refName = "important";
      localName = "Important";
      imapPath = "${foldersPrefix}/${localName}";
      notifyLevel = "notify";
    }

    rec {
      refName = "feed";
      localName = "Feed";
      imapPath = "${foldersPrefix}/${localName}";
      notifyLevel = "totalCount";
    }

    rec {
      refName = "dev";
      localName = "Dev";
      imapPath = "${foldersPrefix}/${localName}";
      notifyLevel = "totalCount";
    }

    rec {
      refName = "notes_to_self";
      localName = "Notes to Self";
      imapPath = "${foldersPrefix}/${localName}";
    }

    rec {
      refName = "paper_trail";
      localName = "Paper Trail";
      imapPath = "${foldersPrefix}/${localName}";
    }

    rec {
      refName = "archive";
      localName = "Archive";
      imapPath = localName;
    }

    rec {
      refName = "screened_out";
      localName = "Screened Out";
      imapPath = "${foldersPrefix}/${localName}";
    }

    rec {
      refName = "spam";
      localName = "Spam";
      imapPath = localName;
    }

    rec {
      refName = "trash";
      localName = "Trash";
      imapPath = localName;
    }
  ];
}
