# General information

## SOPS

The SOPS key needs to be installed at `~/.config/sops/age/keys.txt`.

## Fonts

We used to decrypt our fonts from this repo using SOPS and then derive packages
from them, but it seems that little trick had relied on a bug that has since
been patched (the build environment was no longer able to see the SOPS key at
its absolute path). We now serve these fonts from a simple Nginx server running
in our homelab.

# Notes for installation on new machines

Some notes I've taken from my first experience deploying my config to new
hardware. Each of these headings represents some suckage we should seek to
eliminate, and get as close as possible to `nxrb` and `nxhm` resulting in a
complete, working system. Practice on a VM or even the ThinkPad!

## Davmail

Either copy over an existing `~/.davmail-token.properties` or you'll need to
temporarily change `davmail.mode` to `O365Interactive` and run the Davmail GUI
to generate a new one. We can't just throw this into SOPS secrets, IIRC, because
Davmail will not function if it cannot write to this file (even if it doesn't
actually change it).

## Peroxide

This one is more annoying. `sudo chown -R peroxide:peroxide /var/lib/peroxide`,
`sudo peroxide-cfg -action login-account -account-name "<email>"`, then restart
the service with `systmctl restart peroxide`.

## mbsync

You should now be able to `mbsync` for each account successfully. These will
take a while! Or copy the `~/mail` dir from a previous machine to greatly speed
up the initial sync.

## Vdirsyncer

You should now also be able to `systemctl restart --user vdirsyncer`

## Browsers

Extensions and extension settings are imperative. Copying the
`.config/<browser>` directories over from a previous computer works fine, and
brings history and tabs with it, which is nice.

## Git config and work-related SSH config

As it says. We can probably just throw these into SOPS and call it a day.
