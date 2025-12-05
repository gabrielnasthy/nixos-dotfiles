{ config, pkgs, ... }: # Removi 'inputs' para evitar erro se não estiver usando flake.nix

{
  imports =
    [
      # Hardware detectado
      ./hardware-configuration.nix

      # Módulos modulares
      ./modules/virtualization.nix
      ./modules/users.nix

      # Home Manager como módulo do NixOS (via canal <home-manager>)
      # Removemos 'inputs' (flakes), então usamos o caminho de módulo tradicional.
      (import <home-manager/nixos>)
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
  # Garantir locale padrão para todas as sessões (inclui apps GTK como Virt-Manager)
  environment.sessionVariables = {
    LANG = "pt_BR.UTF-8";
    LC_ALL = "pt_BR.UTF-8";
  };
  # Lista de locais suportados para evitar fallback em apps
  i18n.supportedLocales = [ "pt_BR.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

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

  # Habilita Flatpak (Essencial para o Zen Browser)
  services.flatpak.enable = true;

  # Define usuário Rocha
  users.users.rocha = {
    isNormalUser = true;
    description = "Gabriel Aguiar Rocha";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      # Aqui entram pacotes específicos apenas do usuário, se quiser separar.
    ];
  };

  # Permite softwares proprietários (VS Code, Drivers, etc)
  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  # Zsh precisa estar habilitado no nível do sistema para ser shell padrão
  programs.zsh.enable = true;

  # Home Manager (quando usado como módulo NixOS) configura políticas globais aqui
  home-manager.backupFileExtension = "hm-backup"; # faz backup de dotfiles existentes ao ativar HM

  # Fontes: JetBrains Mono Nerd Font no sistema
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
  };

  # === LISTA DE PACOTES DO SISTEMA ===
  environment.systemPackages = with pkgs; [
    # Utilitários Básicos
    git
    wget
    vim
    unzip
    zsh
    
    # Desenvolvimento
    vscode    # VS Code
    
    # Toolchain Rust
    rustup    # Gerenciador de versões (melhor que instalar rustc direto)
    gcc       # Necessário para o Linker do Rust funcionar
    pkg-config
    openssl
  ];

  system.stateVersion = "25.11";
}
