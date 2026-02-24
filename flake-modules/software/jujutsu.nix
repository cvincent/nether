{ name, mkSoftware, ... }:
mkSoftware name (
  {
    jujutsu,
    config,
    pkgs,
    ...
  }:
  {
    nixos =
      let
        fzf-jj-change-ids = (
          pkgs.writeShellApplication {
            name = "fzf-jj-change-ids";
            runtimeInputs = [
              config.nether.software.jujutsu.package
              config.nether.software.fzf.fzf-with-opts
            ];
            text = ''
              if [[ $(echo "$1" | cut -d' ' -f2) == "absorb" ]]; then
                jj diff --name-only |
                  fzf --height=50%
              else
                template='
                  format_short_change_id(change_id) ++
                  " - " ++
                  if(self.empty(), empty_commit_marker ++ " ") ++
                  description.first_line() ++
                  " (" ++ commit_id.short() ++ ")|" ++
                  change_id.shortest() ++ "\n"
                '

                jj log --no-graph --color=always -T "$template" |
                  fzf --ansi --height=50% --delimiter='|' --with-nth='{1}' --accept-nth='{2}'
              fi
            '';
          }
        );
      in
      {
        nether.software.contextual-completion.completionScripts.jj = fzf-jj-change-ids;
      };

    hm = {
      programs.jujutsu = {
        inherit (jujutsu) enable package;

        settings = {
          "$schema" = "https://jj-vcs.github.io/jj/latest/config-schema.json";

          user = {
            name = config.nether.me.fullName;
            email = config.nether.me.email;
          };

          colors = {
            "diff token" = {
              reverse = true;
              underline = false;
            };
          };

          git = {
            private-commits = "private()";
          };

          revset-aliases = {
            "trunk()" = "main@origin";
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
            "closest_pushable(to)" = "heads(::to & ~description(exact:'') & (~empty() | merges()))";
            "private()" = ''description(glob-i:"private:*") | description(glob-i:"wip:*")'';
          };

          aliases = {
            tug = [
              "bookmark"
              "move"
              "--from"
              "closest_bookmark(@)"
              "--to"
              "closest_pushable(@)"
            ];
          };

          ui = {
            diff-editor = "neovim-fugitive";
            merge-editor = "neovim-diffconflicts";

            default-command = [
              "log"
              "-r"
              "reachable(@, mutable()) | (reachable(@, mutable()))-"
              "-T"
              "log_oneline"
            ];
          };

          merge-tools = {
            neovim-fugitive = {
              program = "sh";
              edit-args = [
                "-c"
                ''
                  set -eu
                  rm -f "$right/JJ-INSTRUCTIONS"
                  git -C "$left" init -q
                  git -C "$left" add -A
                  git -C "$left" commit -q -m baseline --allow-empty # create parent commit
                  mv "$left/.git" "$right"
                  git -C "$right" add --intent-to-add --ignore-removal . # create current working copy
                  (cd "$right"; nvim .git/index)
                  git -C "$right" diff-index --quiet --cached HEAD && { echo "No changes done, aborting split."; exit 1; }
                  git -C "$right" commit -q -m split # create commit on top of parent including changes
                  git -C "$right" restore . # undo changes in modified files
                  git -C "$right" reset .   # undo --intent-to-add
                  git -C "$right" clean -q -df # remove untracked files
                ''
              ];
            };

            neovim-diffconflicts = {
              program = "nvim";

              merge-args = [
                "-c"
                "let g:jj_diffconflicts_marker_length=$marker_length"
                "-c"
                "JJDiffConflicts!"
                "$output"
                "$base"
                "$left"
                "$right"
              ];

              merge-tool-edits-conflict-markers = true;
            };
          };

          template-aliases = {
            log_oneline = "log_oneline(self)";
            "log_oneline(commit)" = ''
              if(commit.root(),
                format_root_commit(commit),
                label(
                  separate(" ",
                    if(commit.current_working_copy(), "working_copy"),
                    if(commit.immutable(), "immutable", "mutable"),
                    if(commit.conflict(), "conflicted"),
                  ),
                  concat(
                    separate(" ",
                      format_short_change_id_with_hidden_and_divergent_info(commit),
                      format_short_signature_oneline(commit.author()),
                      if(commit.conflict(), label("conflict", "conflict")),
                      if(config("ui.show-cryptographic-signatures").as_boolean(),
                        format_short_cryptographic_signature(commit.signature())),
                      if(commit.empty(), empty_commit_marker),
                      if(commit.description(),
                        commit.description().first_line(),
                        label(if(commit.empty(), "empty"), description_placeholder),
                      ),
                      commit.bookmarks(),
                      commit.tags(),
                      commit.working_copies(),
                      if(commit.git_head(), label("git_head", "git_head()")),
                    ) ++ "\n",
                  ),
                )
              )
            '';
          };
        };
      };
    };
  }
)
