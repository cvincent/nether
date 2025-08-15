# TODO: Make this compositor agnostic
[
  {
    class = "kitty-scratch";
    command = "uwsm app -- kitty --class kitty-scratch";
    binding = "SUPER, t";
  }
  {
    name = "pavucontrol";
    class = "org.pulseaudio.pavucontrol";
    command = "pavucontrol";
    binding = "SUPER SHIFT, M";
  }
  {
    class = "obsidian-scratch";
    command = "uwsm app -- kitty --class obsidian-scratch nvim --listen /tmp/obsidian.pipe -S /home/cvincent/second-brain/Session.vim";
    binding = "SUPER, o";
    size = "90% 90%";
  }
  {
    class = "smartcalc-tui-scratch";
    command = "uwsm app -- kitty --class smartcalc-tui-scratch smartcalc-slow-start";
    binding = "SUPER, c";
  }
  {
    class = "aerc-scratch";
    command = "uwsm app -- kitty --class aerc-scratch aerc";
    binding = "SUPER, e";
  }
]
