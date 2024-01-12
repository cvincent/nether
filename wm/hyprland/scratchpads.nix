[
  {
    class = "kitty-scratch";
    command = "nvidia-offload kitty --class kitty-scratch -o background_opacity=0.75";
    binding = "SUPER, t";
  }
  {
    class = "pavucontrol";
    command = "pavucontrol";
    binding = "SUPER SHIFT, M";
  }
  {
    class = "ytsub-scratch";
    command = "nvidia-offload kitty --class ytsub-scratch -o background_opacity=0.75 ytsub";
    binding = "SUPER, y";
  }
  {
    class = "neorg-scratch";
    command = "nvidia-offload kitty --class neorg-scratch -o background_opacity=0.75 nvim -S /backup/vim-notes/neorg/Session.vim";
    binding = "SUPER, o";
    size = "60% 80%";
  }
  {
    class = "spotify-tui-scratch";
    command = "nvidia-offload kitty --class spotify-tui-scratch -o background_opacity=0.75 spt";
    binding = "SUPER, m";
  }
  {
    class = "smartcalc-tui-scratch";
    command = "nvidia-offload kitty --class smartcalc-tui-scratch -o background_opacity=0.75 smartcalc-slow-start";
    binding = "SUPER, c";
  }
]
