{ name, mkSoftware, ... }:
mkSoftware name (
  { jujutsu, config, ... }:
  {
    hm.programs.jujutsu = {
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
                git -C "$right" add --intent-to-add -A # create current working copy
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
      };
    };
  }
)
