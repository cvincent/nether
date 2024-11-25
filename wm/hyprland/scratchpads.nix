[
  {
    class = "kitty-scratch";
    command = "nvidia-offload kitty --class kitty-scratch";
    binding = "SUPER, t";
  }
  {
    class = "pavucontrol";
    command = "pavucontrol";
    binding = "SUPER SHIFT, M";
  }
  {
    class = "ytsub-scratch";
    command = "nvidia-offload kitty --class ytsub-scratch ytsub";
    binding = "SUPER, y";
  }
  {
    class = "neorg-scratch";
    command = "nvidia-offload kitty --class neorg-scratch nvim --listen /tmp/neorg.pipe -S /backup/vim-notes/neorg/Session.vim";
    binding = "SUPER, o";
    size = "90% 90%";
  }
  {
    class = "spotify-tui-scratch";
    command = "nvidia-offload kitty --class spotify-tui-scratch ncspot";
    binding = "SUPER, m";
  }
  {
    class = "smartcalc-tui-scratch";
    command = "nvidia-offload kitty --class smartcalc-tui-scratch smartcalc-slow-start";
    binding = "SUPER, c";
  }
  {
    class = "aerc-scratch";
    command = "nvidia-offload kitty --class aerc-scratch aerc";
    binding = "SUPER, e";
  }
]
