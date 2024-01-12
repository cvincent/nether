{ myUsername, ... }:

{
  hardware.uinput.enable = true;
  users.groups.uinput.members = [myUsername];
  users.groups.input.members = [myUsername];
}
