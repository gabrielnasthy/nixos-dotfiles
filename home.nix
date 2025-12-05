{ config, pkgs, lib, ... }:

# Home Manager do usuário principal
# Por quê: gerenciar Zsh, tema P10k e plugins de forma declarativa.

{

  # Pacotes de usuário (apps pessoais; mantenha globais no systemPackages)
  home.packages = with pkgs; [
    bat
    ripgrep
    fd
    eza
    zoxide
    # Toolchain Rust
    rustup
    # Use rust-analyzer via rustup or rely on editor integration; avoid duplication conflicts
    sccache
    pkg-config
    openssl
  ];

  programs.home-manager.enable = true;

  # Zsh com Oh My Zsh, plugins e Powerlevel10k
  programs.zsh = {
    enable = true;

    # Oh My Zsh como framework
    oh-my-zsh = {
      enable = true;
      # Não usar tema do OMZ para P10k; vamos carregar via initContent.
      theme = "robbyrussell";
      # Plugins do OMZ: manter apenas os nativos para evitar "plugin not found"
      plugins = [ "git" "sudo" ];
    };

    # Plugins adicionais via pacotes Nix
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
      {
        name = "zsh-autocomplete";
        src = pkgs.zsh-autocomplete;
      }
    ];

    # Inicialização: carrega configuração P10k do usuário, se existir
    initContent = ''
      # Carregar Powerlevel10k
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Carregar configuração personalizada, se presente
      if [[ -f "$HOME/.p10k.zsh" ]]; then
        source "$HOME/.p10k.zsh"
      fi

      # Atalhos de navegação avançada (zoxide)
      eval "$(zoxide init zsh)"

      # Alias para eza como ls com ícones e cores
      alias ls='eza --group-directories-first --icons --color=always'
      alias ll='eza -la --group-directories-first --icons --color=always'
      alias lt='eza -T --group-directories-first --icons --color=always'

      # Inicialização de completion
      autoload -U compinit; compinit

      # Carregar plugins diretamente do Nix store para evitar depender de $ZSH_CUSTOM
      # Ordem sugerida: autocomplete -> autosuggestions -> (fast-)syntax-highlighting
      source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      # Use fast-syntax-highlighting (mais rápido); se desejar, mantenha ambos
      source ${pkgs.zsh-fast-syntax-highlighting}/share/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
      # Alternativamente, o clássico syntax-highlighting
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };

  # Para compatibilidade com Oh My Zsh: criar plugins no $ZSH_CUSTOM/plugins que
  # fazem source dos arquivos dos pacotes do Nix. Assim, OMZ encontra os plugins
  # sem precisar de git clone.
  # Removido: loaders em $ZSH_CUSTOM; carregamos via initContent acima para confiabilidade

  # Integração nativa do zoxide via Home Manager (além do init acima)
  programs.zoxide.enable = true;

  # Git básico (exemplo)
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "gabrielnasthy";
        email = "g.rocha@estudante.ifmt.edu.br";
      };
    };
  };

  # Estado do Home Manager
  home.stateVersion = "25.11"; # alinhado ao seu NixOS
}
