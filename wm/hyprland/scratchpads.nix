[
  {
    class = "kitty-scratch";
    command = "kitty --class kitty-scratch";
    binding = "SUPER, t";
  }
  {
    name = "pavucontrol";
    class = "org.pulseaudio.pavucontrol";
    command = "pavucontrol";
    binding = "SUPER SHIFT, M";
  }
  {
    class = "ytsub-scratch";
    command = "kitty --class ytsub-scratch ytsub";
    binding = "SUPER, y";
  }
  {
    class = "neorg-scratch";
    command = "kitty --class neorg-scratch env NEORG=1 nvim --listen /tmp/neorg.pipe -S /backup/vim-notes/neorg/Session.vim";
    binding = "SUPER, o";
    size = "90% 90%";
  }
  {
    class = "spotify-tui-scratch";
    command = "kitty --class spotify-tui-scratch ncspot";
    binding = "SUPER, m";
  }
  {
    class = "smartcalc-tui-scratch";
    command = "kitty --class smartcalc-tui-scratch smartcalc-slow-start";
    binding = "SUPER, c";
  }
  {
    class = "aerc-scratch";
    command = "kitty --class aerc-scratch aerc";
    binding = "SUPER, e";
  }
]
