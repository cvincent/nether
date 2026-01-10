{ name, mkSoftware, ... }:
mkSoftware name (
  {
    aerc,
    lib,
    pkgs,
    nether,
    hmConfig,
    ...
  }:
  let
    totalCountScripts =
      aerc.accountConfigs
      |> lib.mapAttrs' (
        account: accountConfig: {
          name = account;
          value = pkgs.writeShellApplication {
            name = "${aerc.countUnreadEmailScript.name}-${account}-total";
            runtimeInputs = [
              aerc.countUnreadEmailScript
              nether.software.jq.package
            ];
            text = builtins.readFile (
              pkgs.replaceVars ./account-total-count.bash {
                inherit account;
                inherit (aerc) mailConfigFilePath;
              }
            );
          };
        }
      );
  in
  {
    options = {
      accountConfigs = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };

      mailConfigFilePath = lib.mkOption { type = lib.types.str; };
      mailCacheBasePath = lib.mkOption { type = lib.types.str; };
      countUnreadEmailScript = lib.mkOption { type = lib.types.package; };

      clearCountUnreadEmailCacheScript = lib.mkOption {
        type = lib.types.package;
        default = pkgs.writeShellApplication {
          name = "clear-count-unread-email-cache";
          text = "rm -f ${aerc.mailCacheBasePath}/*";
        };
      };
    };

    hm = {
      accounts.email.accounts =
        aerc.accountConfigs
        |> builtins.mapAttrs (
          account: accountConfig: {
            aerc = {
              enable = true;

              extraAccounts =
                let
                  encodedEmail = pkgs.lib.strings.escapeURL accountConfig.email;
                  encodedPassword = pkgs.lib.strings.escapeURL accountConfig.imap.password;
                in
                {
                  outgoing =
                    let
                      inherit (accountConfig.smtp) scheme host;
                      port = toString accountConfig.smtp.port;
                    in
                    "${scheme}://${encodedEmail}:${encodedPassword}@${host}:${port}";

                  original-to-header = "To";

                  default = accountConfig.folders.important.localName;

                  folders = accountConfig.foldersOrder;
                  folders-sort = accountConfig.foldersOrder;

                  folder-map = builtins.toFile "${account}-folder-map" (
                    accountConfig.folders
                    |> lib.mapAttrsToList (_: { localName, imapPath, ... }: ''"${localName}" = "${imapPath}"'')
                    |> builtins.concatStringsSep "\n"
                  );

                  archive = accountConfig.folders.archive.localName;
                  postpone = accountConfig.folders.drafts.localName;

                  signature-file = builtins.toFile "${account}-sig" accountConfig.signature;

                  # No-op, but allows us to run `:check-mail`, which forces aerc to refresh its counts
                  check-mail-cmd = "echo check";
                  check-mail = "1s";

                  # TODO: Still need to figure out address-book-cmd using
                  # HM-based config... We should also set our aliases, which are
                  # private.
                }
                // (if accountConfig.smtp.copyTo then { copy-to = accountConfig.folders.sent.localName; } else { })
                // (
                  if builtins.length accountConfig.aliases == 0 then
                    { }
                  else
                    {
                      aliases =
                        accountConfig.aliases
                        |> (map (email: ''"${nether.me.fullName}" <${email}>''))
                        |> (builtins.concatStringsSep ",");
                    }
                );
            };
          }
        );

      programs.aerc = {
        inherit (aerc) enable package;

        extraConfig =
          let
            perAccountConfigs = (
              aerc.accountConfigs
              |> lib.mapAttrs' (
                account: accountConfig: {
                  name = "ui:account=${account}";
                  value =
                    let
                      totalCountScript = totalCountScripts.${account};

                      ignoreUnreadCountFolders =
                        accountConfig.folders
                        |> lib.filterAttrs (refName: _: !builtins.elem refName accountConfig.totalCountFolders)
                        |> lib.mapAttrsToList (_: folder: "(match .Folder `${folder.localName}`)")
                        |> builtins.concatStringsSep " ";
                    in
                    {
                      tab-title-account = "${accountConfig.displayName} ({{exec `${lib.getExe totalCountScript}` \"\"}})";
                      dirlist-left = ''{{if or ${ignoreUnreadCountFolders} (not .Unread)}}{{.Folder}}{{else}}{{.Style .Folder "our_dirlist_unread"}}{{end}}'';
                      dirlist-right = ''{{if or ${ignoreUnreadCountFolders} (not .Unread)}}{{else}}{{.Style (humanReadable .Unread) "our_dirlist_unread"}}{{end}}'';
                    };
                }
              )
            );
          in
          perAccountConfigs
          // {
            general = {
              # Allows aerc to start even though our accounts.conf file is in the
              # Nix store, therefore with open permissions.
              unsafe-accounts-conf = true;

              default-save-path = nether.downloadsDirectory;
              log-file = "${nether.homeDirectory}/.local/state/aerc/log";

              # For hyperlinks
              enable-osc8 = true;

              default-menu-cmd = lib.getExe nether.software.fzf.fzf-with-opts;
            };

            ui = {
              sidebar-width = 22;
              dirlist-delay = "100ms";
              dirlist-tree = false; # Looks nice but then we can't control the order with folders-sort
              sort = "-r date";
              threading-enabled = true;
              msglist-scroll-offset = 3;
              empty-message = "🕺";
              new-message-bell = false;
              tab-title-account = "{{.Account}}{{if .Unread}} ({{.Unread}}){{end}}";
              icon-attachment = "󰏢";
              icon-new = "";
              icon-old = "";
              icon-replied = "";
              icon-forwarded = "";
              icon-flagged = "";
              icon-marked = "";
              icon-draft = "󰏫";
              icon-deleted = "";
              fuzzy-complete = true;
              thread-prefix-tip = "╼";
              thread-prefix-folded = ''" "'';
              thread-prefix-indent = "";
              thread-prefix-stem = "│";
              thread-prefix-limb = "─";
              thread-prefix-unfolded = "";
              thread-prefix-first-child = "┬";
              thread-prefix-has-siblings = "├";
              thread-prefix-orphan = ''"┌ "'';
              thread-prefix-dummy = "┬";
              thread-prefix-lone = " ";
              thread-prefix-last-sibling = "╰";
              this-day-time-format = "3:04pm";
            };

            "ui:folder=Archive" = {
              threading-enabled = false;
            };

            "ui:folder=Important" = {
              sort = "-r read -r date";
            };

            "ui:folder=Feed" = {
              sort = "-r read -r date";
            };

            # statusline.display-mode = "icon"; # Don't love the emojis
            # Good to know, we can display info about the current message,
            # e.g. would be alright to see where we're at in a thread in view
            # mode.
            # statusline.column-center = "- {{.Subject}} -";
            # Don't flap "Checking for new mail..."
            statusline.column-left = "[{{.Account}}]";

            viewer = {
              pager = "${lib.getExe nether.software.neovim.package} +Man! -c ZenMode";
            };

            compose = {
              editor = "nvim";
              reply-to-self = false; # If replying to ourselves in a thread, send it to the original To/Cc
              no-attachment-warning = "^[^>]*attach(ed|ment)";

              # TODO: When we get to contacts stuff. This will be nice if we
              # can get address completion into NeoVim, would allow us to set
              # the to/subject/etc directly in NeoVim, with all the editing
              # goodness that implies:
              # edit-headers = true;

              # TODO: When/if we figure out oil.nvim as a file-picker.
              # file-picker-cmd = "oil.nvim";
            };

            multipart-converters =
              let
                preserveSignatureLinebreaks = pkgs.writeShellApplication {
                  name = "preserve-sig-linebreaks";
                  text = builtins.readFile ./sig-to-markdown.bash;
                };
              in
              {
                # Convert our plaintext messages to HTML via Markdown; note that
                # apparently some mailing lists will reject emails with
                # text/html.
                "text/html" =
                  [
                    (lib.getExe pkgs.dos2unix)
                    (lib.getExe preserveSignatureLinebreaks)
                    "${lib.getExe pkgs.pandoc} -f markdown -t html -s"
                  ]
                  |> builtins.concatStringsSep " | ";
              };

            filters = {
              "text/plain" = "colorize";
              "message/delivery-status" = "colorize";
              "message/rfc822" = "colorize";
              "text/html" = lib.getExe pkgs.html2text;
              ".headers" = "colorize";
              "text/calendar" = "calendar";
              "application/pdf" =
                "${lib.getExe' pkgs.poppler-utils "pdftotext"} - -l 10 -nopgbrk -q  - | fmt -w 72";
            };

            hooks = {
              aerc-startup = lib.getExe aerc.clearCountUnreadEmailCacheScript;
              mail-received = lib.getExe aerc.clearCountUnreadEmailCacheScript;
              mail-deleted = lib.getExe aerc.clearCountUnreadEmailCacheScript;
              mail-added = lib.getExe aerc.clearCountUnreadEmailCacheScript;
              flag-changed = lib.getExe aerc.clearCountUnreadEmailCacheScript;
            };

            # TODO: When we get to calendar stuff. The :accept command can be
            # used to send the accept message, with `-s` to skip the editor
            # and go straight to confirmation. There is also :accept-tentative
            # and :decline.

            # TODO: When we get to calendar stuff. This is how we'll do stuff
            # like easily import invites into our calendar.
            # openers = {};
          };

        extraBinds =
          let
            perAccountBinds =
              (
                aerc.accountConfigs
                |> lib.mapAttrs' (
                  account: accountConfig:
                  let
                    fileScriptPath = lib.getExe nether.software.imapfilter.fileEmailScripts.${account};
                  in
                  {
                    name = "messages:account=${account}";
                    value = {
                      F = ":menu -d -t 'File sender(s)' :pipe -bm ${fileScriptPath}<enter>";
                      D = ":read<enter>:remark<enter>:move ${accountConfig.folders.trash.localName}<enter>";
                    };
                  }
                )
              )
              // (
                aerc.accountConfigs
                |> lib.mapAttrs' (
                  account: accountConfig: {
                    name = "view:account=${account}";
                    value = {
                      # Needs to be specified here otherwise these per-account
                      # configs reset it
                      "$ex" = "<a-;>";
                      "<a-o>" = ":open qutebrowser-open ${account}<enter>";
                    };
                  }
                )
              )
              // (
                aerc.accountConfigs
                |> lib.mapAttrs' (
                  account: accountConfig:
                  let
                    sendWithHtmlMultipart = ":multipart text/html<enter>:send<enter> # Send with HTML part";
                    sendPlainText = ":send<enter> # Send plaintext only";
                  in
                  {
                    name = "compose::review:account=${account}";
                    value =
                      if accountConfig.smtp.htmlMultipart then
                        {
                          y = sendWithHtmlMultipart;
                          Y = sendPlainText;
                        }
                      else
                        {
                          y = sendPlainText;
                          Y = sendWithHtmlMultipart;
                        };
                  }
                )
              );
          in
          perAccountBinds
          // rec {
            global = {
              "<c-?>" = ":help keys<enter>";
            };

            messages = {
              "<Left>" = ":prev-tab<enter>";
              "<Right>" = ":next-tab<enter>";
              "<C-t>" = ":term<enter>";
              q = ":prompt 'Quit?' quit<enter>";

              j = ":next<enter>";
              "2j" = ":next 2<enter>";
              "3j" = ":next 3<enter>";
              "4j" = ":next 4<enter>";
              "5j" = ":next 5<enter>";
              "6j" = ":next 6<enter>";
              "7j" = ":next 7<enter>";
              "8j" = ":next 8<enter>";
              "9j" = ":next 9<enter>";
              "10j" = ":next 10<enter>";

              k = ":prev<enter>";
              "2k" = ":prev 2<enter>";
              "3k" = ":prev 3<enter>";
              "4k" = ":prev 4<enter>";
              "5k" = ":prev 5<enter>";
              "6k" = ":prev 6<enter>";
              "7k" = ":prev 7<enter>";
              "8k" = ":prev 8<enter>";
              "9k" = ":prev 9<enter>";
              "10k" = ":prev 10<enter>";

              "<C-d>" = ":next 50%<enter>";
              "<C-u>" = ":prev 50%<enter>";
              gg = ":select 0<enter>";
              G = ":select -1<enter>";

              e = ":envelope<enter>";
              m = ":mark -t<enter>";
              V = ":mark -V<enter>";
              "<esc>" = ":unmark -a<enter>";

              zt = ":align top<enter>";
              zz = ":align center<enter>";
              zb = ":align bottom<enter>";

              # Would love for this to search only From or Subject, but there's
              # no OR operator afaict... Searching the whole text is good enough
              # then.
              "/" = ":clear<enter>:search -a<space>";
              n = ":next-result<enter>";
              N = ":prev-result<enter>";

              za = ":fold -t<enter>";
              zA = ":fold -ta<enter>";
              zc = ":fold<enter>";
              zo = ":unfold<enter>";
              zM = ":fold -a<enter>";
              zR = ":unfold -a<enter>";

              J = ":next-folder<enter>";
              "2J" = ":next-folder 2<enter>";
              "3J" = ":next-folder 3<enter>";
              "4J" = ":next-folder 4<enter>";
              "5J" = ":next-folder 5<enter>";
              "6J" = ":next-folder 6<enter>";
              "7J" = ":next-folder 7<enter>";
              "8J" = ":next-folder 8<enter>";
              "9J" = ":next-folder 9<enter>";
              "10J" = ":next-folder 10<enter>";

              K = ":prev-folder<enter>";
              "2K" = ":prev-folder 2<enter>";
              "3K" = ":prev-folder 3<enter>";
              "4K" = ":prev-folder 4<enter>";
              "5K" = ":prev-folder 5<enter>";
              "6K" = ":prev-folder 6<enter>";
              "7K" = ":prev-folder 7<enter>";
              "8K" = ":prev-folder 8<enter>";
              "9K" = ":prev-folder 9<enter>";
              "10K" = ":prev-folder 10<enter>";

              T = ":toggle-threads<enter>";

              u = ":read -t<enter>j";
              A = ":read<enter>:remark<enter>:archive flat<enter>";
              M = ":menu -dt 'Move to folder' :move<enter>";

              R = ":reply<enter>";
              C = ":compose<enter>";

              "<enter>" = ":view<enter>";
              "<c-enter>" = ":vsplit<enter>";
            };

            view = {
              "$ex" = "<a-;>";
              "q" = ":close<enter>";
              "<a-a>" = ":archive flat<enter>:close<enter>";
              "<a-h>" = ":toggle-headers<enter>";
              "<a-s-j>" = ":next<enter>";
              "<a-s-k>" = ":prev<enter>";
              "<a-j>" = ":next-part<enter>";
              "<a-k>" = ":prev-part<enter>";
            };

            compose = {
              "$ex" = "<a-;>";
              # TODO: When/if we figure out oil.nvim as a file-picker. Would
              # love to use it to select attachments.
              "<a-a>" = ":attach<space>";
              "<a-d>" = ":detach<space>";
              "<a-j>" = ":next-field<enter>";
              "<a-k>" = ":prev-field<enter>";
            };

            "compose::editor" = compose;

            "compose::review" = {
              v = ":preview<enter>";
              p = ":postpone<enter>";
              D = ":abort<enter> # Discard";
              q = ":choose -o d discard abort -o p postpone postpone<enter>";
              e = ":edit<enter>";
              a = ":attach<space>";
              d = ":detach<space>";
            };
          };

        templates.quoted_reply = ''
          X-Mailer: aerc {{version}}

          On {{dateFormat (.OriginalDate | toLocal) "Mon Jan 2, 2006 at 3:04 PM MST"}}, {{.OriginalFrom | names | join ", "}} wrote:

          {{ if eq .OriginalMIMEType "text/html" -}}
          {{- exec `html` .OriginalText | trimSignature | quote -}}
          {{- else -}}
          {{- trimSignature .OriginalText | quote -}}
          {{- end}}
          {{- with .Signature }}

          {{.}}
          {{- end }}
        '';

        stylesets.default = {
          global = {
            "*.default" = true;
            "*.normal" = true;

            "*.selected.bg" = 8;

            "tab.selected.bg" = 4;
            "tab.selected.fg" = 0;

            "msglist_unread.bold" = true;
            "msglist_unread.fg" = 6;
          };

          user = {
            "our_dirlist_unread.bold" = true;
            "our_dirlist_unread.fg" = 6;

            "hide_unread.bold" = false;
            "hide_unread.fg" = 0;
          };
        };
      };
    };
  }
)
