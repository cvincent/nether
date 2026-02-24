{ name, mkSoftware, ... }:
mkSoftware name (
  {
    jujutsu,
    config,
    pkgs,
    helpers,
    ...
  }:
  {
    options = {
      scripts =
        let
          mkJujutsuScript = helpers.mkScript ./scripts;
        in
        builtins.listToAttrs [
          (mkJujutsuScript "fzf-completions" {
            runtimeInputs = [
              pkgs.coreutils
              config.nether.software.jujutsu.package
              config.nether.software.fzf.fzf-with-opts
            ];
          })

          (mkJujutsuScript "jj-split-to-bookmark" {
            runtimeInputs = [
              config.nether.software.jujutsu.package
            ];
          })

          (mkJujutsuScript "jj-split-to-absorb" {
            runtimeInputs = [
              config.nether.software.jujutsu.package
            ];
          })
        ];
    };

    nixos = {
      nether.software.contextual-completion.completionScripts.jj = jujutsu.scripts.fzf-completions;
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

            "private()" = ''
              (
                description(glob-i:"private:*") |
                description(glob-i:"wip:*") |
                description("wip\n") |
                bookmarks("megamerge")
              ) & mine()
            '';
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

            stack_split = [
              "split"
              "-A"
              "trunk()"
              "-B"
              "megamerge"
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
                  set -euo pipefail
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

            git-index = {
              program = "sh";
              edit-args = [
                "-c"
                ''
                  set -euo pipefail

                  TEMP=$(mktemp -d)
                  trap 'rm -rf -- "$TEMP"' EXIT

                  LEFT="$left"
                  RIGHT="$right"

                  # Snapshot the index state into a tree. This strips intent-to-add index entries
                  # which are treated as empty files by ls-files & restore. jj implicitly adds
                  # intent-to-add index entries for new files.
                  TREE="$(git write-tree)"

                  # jj checks out a sparse working copy, limit to that sparse set.
                  find -P "$LEFT" "$RIGHT" \( -type f -o -type l \) -printf '%P\0' |
                    sort -zu >"$TEMP/sparse"

                  # Every pathspec passed to git restore must be in $TREE
                  git ls-tree -rz --name-only --full-tree "$TREE" |
                    sort -zu |
                    comm -z -12 "$TEMP/sparse" - >"$TEMP/restore"

                  # Clear out $RIGHT, then restore $TREE state into it
                  rm -r -- "$RIGHT"
                  mkdir -- "$RIGHT"

                  if [[ -s "$TEMP/restore" ]]; then
                    git --literal-pathspecs --work-tree="$RIGHT" restore \
                      --source="$TREE" \
                      --pathspec-from-file="$TEMP/restore" \
                      --pathspec-file-nul
                  fi
                ''
              ];
            };

            neovim-diffconflicts = {
              program = "nvim";

              merge-args = [
                "--cmd"
                "let g:disable_lsps='true'"
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
                      format_short_change_id_with_change_offset(commit),
                      if(commit.mine(), "", format_short_signature_oneline(commit.author())),
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
                      if(commit.contained_in("first_parent(@)"), label("git_head", "git_head()")),
                    ) ++ "\n",
                  ),
                )
              )
            '';
          };

          templates = {
            draft_commit_description = ''
              concat(
                builtin_draft_commit_description,
                "\nJJ: ignore-rest\n",
                diff.git(),
              )
            '';
          };
        };
      };
    };
  }
)
