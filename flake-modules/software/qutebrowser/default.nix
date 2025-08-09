{ name, mkSoftware, ... }:
mkSoftware name (
  {
    config,
    nether,
    qutebrowser,
    lib,
    pkgs,
    inputs,
    ...
  }:
  {
    nixos.nether.backups.paths."${nether.homeDirectory}/.local/qutebrowsers".deleteMissing = true;

    hm =
      let
        qutebrowser-route = (
          pkgs.writeShellScriptBin "qutebrowser-route" ''
            instance=$(jq --arg url "$1" -r '. | map(. as $item | select($url | test($item.regex))) | .[0].instance' ~/.config/qutebrowser/routes.json)

            if [[ $instance == 'mpv' ]]; then
              mpv "$1" --force-window=immediate
            elif [[ $instance != 'null' ]]; then
              qutebrowser-open "$instance" "$1"
            else
              qutebrowser-open personal "$1"
            fi
          ''
        );
      in
      {
        # TODO: Make...all of this nicer, more modular
        programs.qutebrowser = {
          enable = true;
          package = qutebrowser.package;

          settings = {
            auto_save.session = true;
            session.lazy_restore = true;
            # TODO: We should figure out how to more easily manage the spelling
            # dictionaries. Initially downloading the dictionary is done with:
            # $(find $(nix-store --query --outputs $(which qutebrowser)) -name 'dictcli.py' | head -1) install en-US
            # And then each time we have a new Qutebrowser session instance, it
            # needs a copy of it:
            # cp -R ~/.local/share/qutebrowser/qtwebengine_dictionaries ~/.local/qutebrowsers/personal/qtwebengine_dictionaries
            # Ideally, we would put the dictionary in nether.backups.paths, then
            # each time we create a Qutebrowser instance, symlink that instance's
            # spelling dictionary back to the main one.
            spellcheck.languages = [ "en-US" ];
            input.media_keys = false;

            tabs.position = "right";
            tabs.select_on_remove = "last-used";

            downloads.location.directory = "~/Downloads";
            downloads.location.prompt = false;

            content = {
              autoplay = false;
              cookies.accept = "no-3rdparty";
              geolocation = false;
              notifications.enabled = false;
              register_protocol_handler = false;

              javascript = {
                clipboard = "access-paste";
              };
            };

            editor.command = [
              "kitty"
              "--class=tmp-edit"
              "nvim"
              "{}"
            ];

            statusbar = {
              widgets = [
                "keypress"
                "search_match"
                "url"
                "scroll"
                "progress"
              ];
            };

            colors = {
              webpage.darkmode.enabled = false;

              statusbar = {
                insert.fg = lib.mkForce "#${config.lib.stylix.colors.base00}";
                url = {
                  fg = lib.mkForce "#${config.lib.stylix.colors.base05}";
                  hover.fg = lib.mkForce "#${config.lib.stylix.colors.base05}";
                  success.http.fg = lib.mkForce "#${config.lib.stylix.colors.base05}";
                  success.https.fg = lib.mkForce "#${config.lib.stylix.colors.base05}";
                  warn.fg = lib.mkForce "#${config.lib.stylix.colors.base05}";
                };
              };

              tabs = {
                odd.bg = lib.mkForce "#${config.lib.stylix.colors.base00}";
                even.bg = lib.mkForce "#${config.lib.stylix.colors.base00}";
                pinned.odd.bg = lib.mkForce "#${config.lib.stylix.colors.base00}";
                pinned.even.bg = lib.mkForce "#${config.lib.stylix.colors.base00}";
              };
            };
          };

          extraConfig = ''
            config.set("content.media.audio_capture", True, "https://app.zoom.us")
            config.set("content.media.audio_video_capture", True, "https://app.zoom.us")
          '';

          keyBindings = {
            normal = {
              # Scrolling
              j = "scroll-page 0 0.025";
              k = "scroll-page 0 -0.025";
              d = "scroll-page 0 0.5";
              u = "scroll-page 0 -0.5";
              "<ctrl-j>" = "scroll down";
              "<ctrl-k>" = "scroll up";
              "<ctrl-d>" = "cmd-repeat 10 scroll down";
              "<ctrl-u>" = "cmd-repeat 10 scroll up";

              # Tabs
              D = "tab-close";
              U = "undo";
              "<right>" = "tab-next";
              "<left>" = "tab-prev";
              "<ctrl-right>" = "tab-move +";
              "<ctrl-left>" = "tab-move -";
              x = "config-cycle tabs.position top right";
              "<space>ft" = "cmd-set-text -s :tab-select";
              T = "tab-focus";

              # Easy esc in normal mode
              e = "fake-key <esc>";

              # Same as my NeoVim
              "<return>" = "cmd-set-text :";

              # Videos
              "<space>fv" =
                "hint links spawn mpv --force-window=immediate --no-terminal --keep-open=yes --http-proxy='https://192.168.1.114:8888' --ytdl-raw-options='proxy=http://192.168.1.114:8888' {hint-url}";
              "<space>fV" =
                "hint links spawn yt-dlp -P home:~/videos/youtube/ -P temp:~/videos/youtube/.tmp/ -o '%(duration)s - %(uploader)s - %(title)s.%(ext)s' --embed-chapters --proxy http://192.168.1.114:8888 {hint-url}";
              "yv" =
                "spawn mpv --force-window=immediate --no-terminal --keep-open=yes --http-proxy='https://192.168.1.114:8888' {url}";
              "yV" =
                "spawn yt-dlp -P home:~/videos/youtube/ -P temp:~/videos/youtube/.tmp/ -o '%(duration)s - %(uploader)s - %(title)s.%(ext)s' --embed-chapters --proxy http://192.168.1.114:8888 {url}";

              # Downloads
              "<space>dc" = "download-clear";

              # Same as normal browsers
              "<ctrl-l>" = "edit-url";

              # BitWarden
              "<ctrl-shift-l>" =
                "spawn --userscript /etc/profiles/per-user/${nether.username}/bin/bitwarden-qutebrowser";
              "<space>bc" =
                "spawn --userscript /etc/profiles/per-user/${nether.username}/bin/bitwarden-create login {url}";
              "<space>bf" =
                "spawn --userscript /etc/profiles/per-user/${nether.username}/bin/bitwarden-fuzzel {url:host}";

              # Other
              "<space>wi" = "devtools";
            };
          };

          searchEngines = {
            DEFAULT = "https://kagi.com/search?q={}";
            am = "https://www.amazon.com/s?k={}";
            yt = "https://www.youtube.com/results?search_query={}";
          }
          // inputs.private-nethers.qutebrowser.searchEngines;
        };

        home.file."./.config/qutebrowser/work.py".source = ./work.py;
        home.file."./.config/qutebrowser/routes.json".text = inputs.private-nethers.qutebrowser.routes;

        home.packages = [
          pkgs.socat

          (pkgs.writeShellScriptBin "qutebrowser-fuzzel" ''
            if [[ -n "$1" ]]; then
              profile="$1"
            else
              mkdir -p ~/.local/qutebrowsers
              profiles=$(find ~/.local/qutebrowsers -maxdepth 1 -type d | xargs basename -a | grep -v qutebrowsers)
              profile=$(echo "$profiles" | fuzzel --prompt='Qutebrowser ❯ ' -d)
            fi

            if [[ -z "$profile" ]]; then exit 0; fi

            config=~/.config/qutebrowser/$profile.py
            if [[ ! -f "$config" ]]; then config=~/.config/qutebrowser/config.py; fi

            qutebrowser -C $config --basedir ~/.local/qutebrowsers/$profile --desktop-file-name qute-$profile -r default
          '')

          (pkgs.writeShellScriptBin "qutebrowser-open" ''
            ipc=$(find ~/.local/qutebrowsers/''\$1/runtime | grep '/ipc-' | xargs basename)
            echo "{\"args\": [\"$2\"], \"target_arg\": \"\", \"protocol_version\":1}" | socat - UNIX-CONNECT:"/home/cvincent/.local/qutebrowsers/$1/runtime/$ipc"
          '')

          qutebrowser-route

          (pkgs.makeDesktopItem {
            name = "qutebrowser-route";
            desktopName = "qutebrowser-route";
            exec = "${qutebrowser-route}/bin/qutebrowser-route %U";
          })
        ];

        xdg.mimeApps = {
          enable = true;

          defaultApplications = {
            "application/x-mimearchive" = "qutebrowser-route.desktop";
            "text/html" = "qutebrowser-route.desktop";
            "x-scheme-handler/http" = "qutebrowser-route.desktop";
            "x-scheme-handler/https" = "qutebrowser-route.desktop";
            "x-scheme-handler/about" = "qutebrowser-route.desktop";
            "x-scheme-handler/unknown" = "qutebrowser-route.desktop";
          };
        };
      };
  }
)
