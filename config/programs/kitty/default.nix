{ ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      linux_display_server = "wayland";
      wayland_titlebar_color = "background";
      background_opacity = "0.9";
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
      font_family = "JetBrainsMono Nerd Font";
      font_size = "12.0";
      term = "xterm-256color";
      # Cache la titlebar
      hide_window_decorations = "yes";
    };
  };
}
