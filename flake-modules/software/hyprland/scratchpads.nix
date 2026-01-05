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
    class = "kitty-obsidian-scratch";
    command = "uwsm app -- kitty --class kitty-obsidian-scratch nvim --listen /tmp/obsidian.pipe -S /home/cvincent/second-brain/Session.vim";
    binding = "SUPER, o";
    size = "window_w*0.90 window_h*0.90";
  }
  {
    class = "kitty-smartcalc-tui-scratch";
    command = "uwsm app -- kitty --class kitty-smartcalc-tui-scratch smartcalc-slow-start";
    binding = "SUPER, c";
  }
  {
    class = "kitty-aerc-scratch";
    command = "uwsm app -- kitty --class kitty-aerc-scratch aerc";
    binding = "SUPER, e";
  }
]
