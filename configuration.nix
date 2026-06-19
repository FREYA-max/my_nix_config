# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }:

{
  # ===========================================================================
  # IMPORTS
  # ===========================================================================
  imports = [
    ./hardware-configuration.nix
    ./nbfc.nix
    <home-manager/nixos>
  ];

  # ===========================================================================
  # SYSTÈME DE BASE
  # ===========================================================================
  system.stateVersion = "25.11";

  networking.hostName = "godfist";

  time.timeZone = "Indian/Antananarivo";

  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  console.keyMap = "us";

  # ===========================================================================
  # UTILISATEURS & SÉCURITÉ
  # ===========================================================================
  users.users.godfist = {
    isNormalUser    = true;
    description     = "godfist";
    extraGroups     = [ "networkmanager" "wheel" "video" "adbusers" "libvirtd" "wireshark" "render" ];
    packages        = with pkgs; [ ];
    useDefaultShell = true;
    shell           = pkgs.zsh;
  };

  security.sudo.extraRules = [
    {
      users = [ "godfist" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.rtkit.enable = true;

  # ===========================================================================
  # NIX & PAQUETS
  # ===========================================================================
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates     = "daily";
    options   = "--delete-older-than 14d";
  };

  documentation = {
    dev.enable = true;
    doc.enable = true;
  };

  # ===========================================================================
  # RÉSEAU
  # ===========================================================================
  networking.networkmanager = {
    enable         = true;
    wifi.powersave = false;
  };

  networking.nftables.enable = true;

  networking.firewall.enable = true;

  networking.nat = {
    enable             = true;
    internalInterfaces = [ "waydroid0" ];
    externalInterface  = "eth0";
  };

  boot.kernelModules = [
    "tcp_bbr"
    "ip_tables"
    "iptable_filter"
    "iptable_nat"
    "iptable_mangle"
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc"          = "fq";
    "net.core.wmem_max"               = 1073741824;
    "net.core.rmem_max"               = 1073741824;
    "net.ipv4.tcp_rmem"               = "4096 87380 1073741824";
    "net.ipv4.tcp_wmem"               = "4096 87380 1073741824";
  };

  # ===========================================================================
  # BOOT & KERNEL
  # ===========================================================================
  boot.loader.systemd-boot.enable      = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.enable      = true;
  boot.loader.grub.device      = "nodev";
  boot.loader.grub.efiSupport  = true;
  boot.loader.grub.splashImage = ./space.png;

  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.plymouth = {
    enable = true;
    theme  = "simple";
    themePackages = [
      (pkgs.stdenv.mkDerivation {
        pname   = "plymouth-theme-simple";
        version = "1.0";
        src     = /etc/nixos/config/programs/plymouth/simple;
        installPhase = ''
          mkdir -p $out/share/plymouth/themes/simple
          cp -r * $out/share/plymouth/themes/simple/
          substituteInPlace $out/share/plymouth/themes/simple/simple.plymouth \
            --replace "@out@" "$out"
        '';
      })
    ];
  };

  boot.consoleLogLevel = 0;
  boot.initrd.verbose  = false;

  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "amd_pstate=active"
    "tsc=reliable"
    "i2c_hid.acpi_probe_timeout=5000"
    "acpi_enforce_resources=lax"
    "i8042.reset"
    "i2c_hid.core_suspend_timeout=2000"
  ];

  boot.initrd.kernelModules = [ ];

  boot.extraModprobeConfig = ''
    options psmouse proto=exps
  '';

  # ===========================================================================
  # CPU & GPU
  # ===========================================================================
  hardware.cpu.amd.updateMicrocode  = true;
  powerManagement.cpuFreqGovernor   = "schedutil";

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
  };


  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.input-sources]
    sources=[('xkb', 'us')]
  '';

  services.thermald.enable = true;

  # 🔴 IMPORTANT : bloquer nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable      = false;
    powerManagement.finegrained = false;

    open           = false;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # 🔥 PRIME (GPU hybride AMD + NVIDIA)
  hardware.nvidia.prime = {
    #sync.enable = true;
    offload = {
      enable           = true;
      enableOffloadCmd = true;
    };

    nvidiaBusId = "PCI:1:0:0";
    amdgpuBusId = "PCI:4:0:0";
  };

  # ===========================================================================
  # AUDIO
  # ===========================================================================
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # ===========================================================================
  # ZRAM
  # ===========================================================================
  zramSwap.enable    = true;
  zramSwap.algorithm = "zstd";

  # ===========================================================================
  # BLUETOOTH
  # ===========================================================================
  hardware.bluetooth.enable = true;
  services.blueman.enable   = true;

  # ===========================================================================
  # BUREAU (KDE Plasma 6 + Hyprland)
  # ===========================================================================
  services.xserver.enable = true;

  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };

  services.displayManager.gdm.enable     = true;
  services.displayManager.gdm.wayland    = true;
  services.desktopManager.plasma6.enable = true;  # KDE
  services.desktopManager.gnome.enable   = true;
  
 # programs.niri.enable = true;
  # programs.hyprland.enable = true;
  # xdg.portal = {
  #   enable       = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-gtk
  #   ];
  # };

  environment.pathsToLink = [ "/share/gsettings-schemas" ];

  # ===========================================================================
  # POLICES DE CARACTÈRES
  # ===========================================================================
  fonts.packages = with pkgs; [
    udev-gothic-nf
    noto-fonts
    liberation_ttf
    font-awesome
  ];

  fonts.fontconfig = {
    enable        = true;
    hinting.style = "slight";
    subpixel.rgba = "rgb";
  };

  # ===========================================================================
  # PROGRAMMES SYSTÈME
  # ===========================================================================
  programs.zsh.enable = true;

  # NOTE : environment.shellAliases s'applique déjà à zsh ET bash,
  # donc programs.zsh.shellAliases / programs.bash.shellAliases (qui
  # ne faisaient que dupliquer ces alias) ont été retirés ci-dessous.
  environment.shellAliases = {
    "."            = "clear";
    abbm           = "steam-run /home/godfist/.local/ABDownloadManager/bin/ABDownloadManager";
    heroic         = "nvidia-offload heroic";
    waydroid-start = "sudo systemctl start waydroid-container && waydroid session start";
    waydroid-ui    = "WAYLAND_DISPLAY=wayland-0 waydroid show-full-ui";
    waydroid-stop  = "waydroid session stop && sudo systemctl stop waydroid-container";
  };

  environment.variables = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    VK_ICD_FILENAMES          = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  };

  programs.adb.enable           = true;
  programs.firefox.enable       = true;
  programs.kdeconnect.enable    = true;
  programs.wireshark.enable     = true;
  programs.virt-manager.enable  = true;

  programs.steam = {
    enable                        = true;
    remotePlay.openFirewall       = true;
    dedicatedServer.openFirewall  = true;
  };

  programs.gamemode.enable  = true;
  programs.dconf.enable     = true;
  programs.ssh.askPassword  = lib.mkForce "";

  # ===========================================================================
  # SERVICES SYSTÈME
  # ===========================================================================
  services.openssh.enable  = true;
  services.printing.enable = true;
  services.flatpak.enable  = true;
  services.touchegg.enable = true;
  services.libinput.enable = true;

  services.libinput.touchpad = {
    tapping            = true;
    naturalScrolling   = true;
    disableWhileTyping = true;
  };

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };

  # ===========================================================================
  # VIRTUALISATION
  # ===========================================================================
  virtualisation.waydroid.enable = true;
  virtualisation.docker.enable   = true;
  virtualisation.lxc.enable      = true;

  virtualisation.libvirtd = {
    enable  = true;
    package = pkgs.libvirt;
    qemu = {
      package   = pkgs.qemu;
      runAsRoot = true;
    };
  };

  # ===========================================================================
  # HOME MANAGER
  # ===========================================================================
  home-manager.backupCommand   = "cp --backup=numbered %s %s";
  home-manager.useGlobalPkgs   = true;
  home-manager.useUserPackages = true;

  home-manager.users.godfist = {
    imports = [ ./home.nix ];
  };

  # ===========================================================================
  # TOUCHPAD (Elantech)
  # ===========================================================================
  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{name}=="PS/2 Generic Mouse", ENV{ID_INPUT_TOUCHPAD}="1", ENV{ID_INPUT_MOUSE}="0", ENV{ID_INPUT}="1"
    SUBSYSTEM=="input", ATTRS{name}=="ETPS/2 Elantech Touchpad", ENV{ID_INPUT_TOUCHPAD}="1", ENV{ID_INPUT_MOUSE}="0", ENV{ID_INPUT}="1"
  '';

  systemd.services.psmouse-reload = {
    description = "Reload psmouse with exps protocol";
    wantedBy = [ "multi-user.target" ];
    after    = [ "systemd-udevd.service" "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "reload-psmouse" ''
        sleep 2
        ${pkgs.kmod}/bin/modprobe -r psmouse
        sleep 1
        ${pkgs.kmod}/bin/modprobe psmouse proto=exps
      '';
      RemainAfterExit = true;
    };
  };

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Enable PS/2 Generic Mouse as touchpad]
    MatchName=PS/2 Generic Mouse
    AttrEventCode=+BTN_TOOL_FINGER
    AttrEventCode=+BTN_TOUCH

    [Enable Elantech Touchpad]
    MatchName=ETPS/2 Elantech Touchpad
    AttrEventCode=+BTN_TOOL_FINGER
    AttrEventCode=+BTN_TOUCH
  '';

  # ===========================================================================
  # PAQUETS SYSTÈME
  # ===========================================================================
  environment.systemPackages = with pkgs; [
    # --- LANCEURS / JEUX / WAYLAND UTILS ---
    heroic
    wineWowPackages.stable
    winetricks
    mangohud
    cava
    wezterm
    wlogout
    wofi
    jq
    imagemagick
    kew
    protonup-ng
    # --- DÉVELOPPEMENT ---
    git
    gnumake
    gcc
    glibc
    rustup
    dotnet-sdk
    jdk8
    jdk21
    openjdk17
    php
    python3Packages.pywal
    python3
    python311
    python314
    godot
    godot-mono
    neovim
    vscodium
    jetbrains.idea-oss
    man
    man-pages-posix
    direnv
    pkgsCross.mingwW64.stdenv.cc
    python3Packages.pip

    # --- TERMINAL & OUTILS CLI ---
    kitty
    ghostty
    btop
    fzf
    bat
    lsd
    neofetch
    fastfetch
    cmatrix
    file
    killall
    inotify-tools
    taskwarrior3
    yq-go
    zbar
    aria2
    wget
    p7zip
    unrar
    yazi
    xfce.thunar
    ascii-image-converter


    # --- MULTIMÉDIA ---
    mpv
    vlc
    ffmpeg
    obs-studio
    mpvpaper
    playerctl

    # --- BUREAU & PRODUCTIVITÉ ---
    libreoffice-qt
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
    obsidian
    papers
    nautilus
    gnome-tweaks
    gnome-shell-extensions
    matugen
    xorg.xf86inputevdev

    # --- AUDIO & WAYLAND OUTILS ---
    grim
    slurp
    satty
    swappy
    eww
    waybar
    quickshell

    # --- INTERNET & COMMUNICATION ---
    brave
    (wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) { })
    telegram-desktop
    qbittorrent
    yt-dlp

    # --- VIRTUALISATION ---
    gnome-boxes
    qemu
    libvirt

    # --- THEMING ---
    kdePackages.qtstyleplugin-kvantum
    catppuccin-kvantum
    catppuccin-kde
    catppuccin-papirus-folders
    catppuccin-cursors

    # --- ENTRÉES & PÉRIPHÉRIQUES ---
    touchegg
    xf86-input-libinput
    wmctrl
    evtest
    xdotool
    xdg-desktop-portal-gtk

    # --- SYSTÈME ---
    nix-ld
    iproute2
    iptables
    power-profiles-daemon
    waydroid
    zenity

    # --- SÉCURITÉ & RÉSEAU ---
    wireshark
    termshark
    nmap
    bettercap
    tcpdump
    metasploit
    sqlmap
    ghidra
    hashcat
    john
    sherlock
    theharvester

    # --- SCRIPTS CUSTOM ---
    (pkgs.writeShellScriptBin "waydroid-launch" ''
      waydroid session start &
      sleep 8
      WAYLAND_DISPLAY=wayland-0 waydroid show-full-ui
    '')
  ];
}
