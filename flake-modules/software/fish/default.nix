{ name, mkSoftware, ... }:
mkSoftware name (
  {
    lib,
    nether,
    fish,
    ...
  }:
  {
    nixos.nether.backups.paths."${nether.homeDirectory}/.local/share/fish/fish_history" = { };

    hm =
      let
        inherit (nether) dotfilesDirectory;
      in
      {
        stylix.targets.fish.enable = false;

        # TODO: Extract a lot of this so it can be more portable between shells
        programs.fish = {
          inherit (fish) enable package;

          interactiveShellInit = ''
            bind \cH backward-kill-word

            # Add OSC 133 support. Allows things like normal mode editing in
            # NeoVim terminal. Doesn't work alongside Starship currently; I've
            # subscribed to the relevant issue:
            # https://github.com/starship/starship/issues/5463
            # Original code from the spec:
            # https://gitlab.freedesktop.org/Per_Bothner/specifications/-/blob/master/proposals/semantic-prompts.md
            if status --is-interactive
              set _fishprompt_aid "fish"$fish_pid
              set _fishprompt_started 0
              # empty if running; or a numeric exit code; or CANCEL
              set _fishprompt_postexec ""

              functions -c fish_prompt _fishprompt_saved_prompt
              set _fishprompt_prompt_count 0
              set _fishprompt_disp_count 0
              function _fishprompt_start --on-event fish_prompt
                set _fishprompt_prompt_count (math $_fishprompt_prompt_count + 1)
                # don't use post-exec, because it is called *before* omitted-newline output
                if [ -n "$_fishprompt_postexec" ]
                  printf "\033]133;D;%s;aid=%s\007" "$_fishprompt_postexec" $_fishprompt_aid
                end
                printf "\033]133;A;aid=%s;cl=m\007" $_fishprompt_aid
              end

              function fish_prompt
              set _fishprompt_disp_count (math $_fishprompt_disp_count + 1)
                printf "\033]133;P;k=i\007%b\033]133;B\007" (string join "\n" (_fishprompt_saved_prompt))
                set _fishprompt_started 1
                set _fishprompt_postexec ""
              end

              function _fishprompt_preexec --on-event fish_preexec
                if [ "$_fishprompt_started" = "1" ]
                  printf "\033]133;C;\007"
                end
                set _fishprompt_started 0
              end

              function _fishprompt_postexec --on-event fish_postexec
                 set _fishprompt_postexec $status
              end

              function __fishprompt_cancel --on-event fish_cancel
                 set _fishprompt_postexec CANCEL
                _fishprompt_start
              end

              function _fishprompt_exit --on-process %self
                if [ "$_fishprompt_started" = "1" ]
                  printf "\033]133;Z;aid=%s\007" $_fishprompt_aid
                end
              end

              if functions -q fish_right_prompt
                functions -c fish_right_prompt _fishprompt_saved_right_prompt
                function fish_right_prompt
                   printf "\033]133;P;k=r\007%b\033]133;B\007" (string join "\n" (_fishprompt_saved_right_prompt))
                end
              end
            end
          '';

          shellAliases = nether.shells.aliases;

          functions = {
            fish_greeting = ''
              echo (
                set_color red; echo "";
                set_color yellow; echo "";
                set_color normal; echo LFG;
                set_color yellow; echo "";
                set_color red; echo ""; set_color normal
              )
            '';

            # NOTE: This is my old prompt. Right now this does nothing because we
            # use Starship. But I liked it, and I don't feel like deleting it.
            # Call me sentimental.
            # fish_prompt = builtins.readFile ./fish_prompt.fish;

            # TODO: This should just be a bash script so we can use it from any
            # shell.
            nxrb = ''
              git -C ${dotfilesDirectory} add -AN
              if sudo nixos-rebuild switch --flake ${dotfilesDirectory} --fast
                notify-send -i dialog-information -t 5000 -e 'NixOS Rebuild Succeeded'
              else
                notify-send -i dialog-error -t 5000 -e 'NixOS Rebuild Failed'
              end
              aplay ${dotfilesDirectory}/resources/notification.wav 2> /dev/null
            '';
          };
        };
      };
  }
)
