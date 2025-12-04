{ config, pkgs, ... }: # Removi 'inputs' para evitar erro se não estiver usando flake.nix

let
  homeManagerTarball = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/programs.nix
      ./modules/hardware-optimizations.nix
      (import "${homeManagerTarball}/nixos")
      ./home.nix
    ];

  # Habilitar funcionalidades experimentais (útil para o futuro)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Firewall (Firewalld)
  networking.firewall.enable = false; # Desabilita o firewall padrão do NixOS
  networking.nftables.enable = true; # Necessário para o Firewalld
  services.firewalld.enable = true;

  # Timezone e Locale
  time.timeZone = "America/Cuiaba";
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Interface Gráfica (KDE Plasma 6)
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Teclado
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
  console.keyMap = "br-abnt2";
  
  services.printing.enable = true;

  # Áudio (Pipewire é o padrão moderno, similar ao Arch)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define usuário Rocha
  users.users.rocha = {
    isNormalUser = true;
    description = "Gabriel Aguiar Rocha";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
      # Aqui entram pacotes específicos apenas do usuário, se quiser separar.
    ];
  };

  system.stateVersion = "25.11";
}
