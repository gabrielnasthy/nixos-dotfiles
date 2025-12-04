{ config, pkgs, lib, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";

  home-manager.users.rocha = { pkgs, lib, ... }: {
    home.username = "rocha";
    home.homeDirectory = "/home/rocha";

    programs.home-manager.enable = true;
    xdg.enable = true;

    home.packages = with pkgs; [
      fastfetch
      eza
      bat
      mesa-demos
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      # Usa caminho absoluto para o diretório de config do Zsh (evita warnings)
      dotDir = "/home/rocha/.config/zsh";
      shellAliases = {
        ls = "eza";
        ll = "eza -al";
        la = "eza -a";
        cat = "bat";
        gs = "git status";
        gl = "git log --oneline --graph --decorate";
        rb = "sudo nixos-rebuild switch";
        hm = "home-manager switch";
        update = "sudo nixos-rebuild switch --upgrade";
      };
      oh-my-zsh = {
        enable = true;
        theme = "powerlevel10k/powerlevel10k";
        plugins = [ "git" "sudo" "z" "history" ];
      };
      initContent = ''
        # Configuração de inicialização do Zsh
        export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
        [[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
      '';
    };

    home.sessionVariables = {
      EDITOR = "vim";
      TERMINAL = "konsole";
    };

    home.file.".oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" = {
      source = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    };

    # Dotfile versionado do Powerlevel10k
    home.file.".p10k.zsh" = {
      source = ./dotfiles/zsh/p10k.zsh;
    };

    programs.git = {
      enable = true;
      userName = "Gabriel Aguiar Rocha";
      userEmail = "G.rocha@estudante.ifmt.edu.br";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    home.activation.installZenBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! ${pkgs.flatpak}/bin/flatpak remote-list --columns=name | grep -qx flathub; then
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      fi
      # Novo ID do Zen Browser no Flathub (substitui io.github.zen_browser.zen)
      if ! ${pkgs.flatpak}/bin/flatpak list --app --columns=application | grep -qx app.zen_browser.zen; then
        ${pkgs.flatpak}/bin/flatpak install -y flathub app.zen_browser.zen
      fi
      # Remove o ID antigo se ainda estiver instalado
      if ${pkgs.flatpak}/bin/flatpak list --app --columns=application | grep -qx io.github.zen_browser.zen; then
        ${pkgs.flatpak}/bin/flatpak uninstall -y io.github.zen_browser.zen || true
      fi
    '';

    home.stateVersion = "24.05";
  };
}
