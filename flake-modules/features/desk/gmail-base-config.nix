rec {
  primary = false;
  email = null;
  aliases = [ ];

  imap = {
    host = "imap.gmail.com";
    port = 993;
    imapFilterSSL = "tls1";
    tls.enable = true;
  };

  smtp = {
    scheme = "smtps+plain";
    host = "smtp.gmail.com";
    port = 465;

    # Gmail automatically copies outgoing email to Sent; if we make our own
    # copies, they end up creating a separate weird folder
    copyTo = false;

    htmlMultipart = true;
  };

  excludeFolders = [ "[Gmail]/Starred" ];

  foldersPrefix = "[Gmail]";

  folderLayout = [
    rec {
      refName = "drafts";
      localName = "Drafts";
      imapPath = "${foldersPrefix}/${localName}";
    }

    {
      refName = "sent";
      localName = "Sent";
      imapPath = "${foldersPrefix}/Sent Mail";
    }

    rec {
      refName = "unscreened";
      localName = "Unscreened";
      imapPath = localName;
      notifyLevel = "totalCount";
    }

    {
      refName = "important";
      localName = "Important";
      imapPath = "Sync Important";
      notifyLevel = "notify";
    }

    rec {
      refName = "feed";
      localName = "Feed";
      imapPath = localName;
      notifyLevel = "totalCount";
    }

    rec {
      refName = "dev";
      localName = "Dev";
      imapPath = localName;
      notifyLevel = "notify";
    }

    rec {
      refName = "notes_to_self";
      localName = "Notes to Self";
      imapPath = localName;
    }

    rec {
      refName = "paper_trail";
      localName = "Paper Trail";
      imapPath = localName;
    }

    {
      refName = "archive";
      localName = "Archive";
      imapPath = "Sync Archive";
    }

    rec {
      refName = "screened_out";
      localName = "Screened Out";
      imapPath = localName;
    }

    rec {
      refName = "spam";
      localName = "Spam";
      imapPath = "${foldersPrefix}/${localName}";
    }

    rec {
      refName = "trash";
      localName = "Trash";
      imapPath = "${foldersPrefix}/${localName}";
    }
  ];
}
