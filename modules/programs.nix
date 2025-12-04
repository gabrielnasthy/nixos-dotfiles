{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };
  hardware.steam-hardware.enable = true;

  services.flatpak.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    vim
    unzip
    fastfetch
    distrobox
    bazaar
    firewalld-gui
    bat
    vscode
    rustup
    rustc
    cargo
    gcc
    pkg-config
    openssl
    cmake
    extra-cmake-modules
    ninja
    mpv
    lz4
    vulkan-headers
    qt5.qtbase
    qt5.qtwebsockets
    qt5.qtwebchannel
    qt5.qtx11extras
    libsForQt5.plasma-framework
    (python3.withPackages (ps: with ps; [ websockets ]))
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    vulkan-tools
    mesa-demos
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.fira-code
  ];
}
