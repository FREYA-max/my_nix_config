{ config, pkgs, lib, pkgs-unstable, ... }:
{
  imports = [
    ./binds.nix
    ./autostart.nix
    ./animations.nix
    ./monitors.nix
    ./window-rules.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];
    settings = {
      general = {
        border_size = 0;
        gaps_in = 5;
        gaps_out = 10;
        layout = "master";
        resize_on_border = true;
      };
      decoration = {
        rounding = 8;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        blur.enabled = false;
        shadow.enabled = false;
      };
      misc = {
        disable_hyprland_logo = true;
        force_default_wallpaper = -1;
        vrr = 0;
      };
      cursor.no_hardware_cursors = 1;
      input = {
        kb_layout = "us";
        touchpad.natural_scroll = true;
        sensitivity = -0.7;
      };
    };
  };
  home.packages = with pkgs; [
    rofi
    pavucontrol
    fortune
    wl-screenrec
    alsa-utils
    swww
    networkmanager_dmenu
    wl-clipboard
    fd
    ripgrep
    gtk3
    cava
    cliphist
    tree
    jq
    socat
    pamixer
    brightnessctl
    acpi
    iw
    bluez
    libnotify
    networkmanager
    lm_sensors
    bc
    pulseaudio
    imagemagick
  ];
  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
