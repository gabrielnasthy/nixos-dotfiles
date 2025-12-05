# Instruções do Copilot para `nixos-modular-config`

Este documento define as regras, estrutura e objetivos para assistentes de IA (GitHub Copilot/Cursor/ChatGPT) ao manipular esta configuração do NixOS. O foco é manter um sistema **modular**, **declarativo** e **reprodutível**, migrando de um estilo monolítico para uma arquitetura organizada.

## Escopo & Objetivos

- **Perfil do Usuário:** Desenvolvedor (foco em Rust), migrando de Arch Linux. Valoriza performance, organização e "infraestrutura como código".
- **Sistema Alvo:** NixOS com KDE Plasma 6.
- **Virtualização:** Implementação de KVM/QEMU com Virt-Manager (prioridade sobre Incus para uso desktop geral).
- **Shell:** Zsh como padrão absoluto, totalmente tunado (Oh My Zsh, Powerlevel10k, plugins).

## Visão Geral da Arquitetura (Estrutura Obrigatória)

Não edite o `configuration.nix` para adicionar pacotes soltos. Use os módulos dedicados.

- **Raiz:** `/etc/nixos/`
- **Entrada Principal:** `configuration.nix` (Gerencia imports e bootloader).
- **Módulos de Sistema (`/modules/`):**
  - `modules/hardware.nix`: Drivers, Kernel Zen, GPU Híbrida, SSDs.
  - `modules/virtualization.nix`: Configuração de KVM, Libvirt e Virt-Manager.
  - `modules/networking.nix`: Hostname, NetworkManager, Locales.
  - `modules/programs.nix`: Pacotes de sistema globais, Steam, Flatpak.
  - `modules/users.nix`: Definição de usuários do sistema e grupos.
- **Home Manager (`home.nix`):**
  - Gerencia dotfiles do usuário, temas, Zsh, Git e configurações de apps específicos.

## Tarefas de Configuração Específicas

Ao gerar código ou refatorar, siga estritamente estas definições:

### 1. Novo Usuário e Home Manager
- Criar/Configurar um usuário principal (ex: `rocha` ou `dev`).
- O Home Manager deve ser configurado como módulo do NixOS (`home-manager.users.<usuario>`) para que um único `nixos-rebuild switch` atualize tudo.

### 2. Zsh & Terminal (A "Stack" de Produtividade)
- O Zsh deve ser habilitado globalmente em `modules/programs.nix`.
- A configuração fina deve estar no `home.nix`:
  - **Framework:** Habilitar `oh-my-zsh`.
  - **Plugins Obrigatórios:** `git`, `sudo`, `zsh-syntax-highlighting`, `zsh-autosuggestions`.
  - **Tema:** Powerlevel10k (P10k).
    - *Nota:* Não use `git clone`. Use o pacote `pkgs.zsh-powerlevel10k` e aponte o source file corretamente no bloco `plugins` do Zsh.
    - Incluir script de inicialização (`initExtra`) para carregar o `~/.p10k.zsh` se existir.

### 3. Virtualização (KVM/QEMU)
- Criar ou editar `modules/virtualization.nix`.
- Habilitar `virtualisation.libvirtd`.
- Habilitar `programs.virt-manager`.
- Garantir que o usuário principal esteja no grupo `libvirtd`.

## Fluxos de Trabalho Críticos

- **Aplicar Mudanças:** `sudo nixos-rebuild switch`
- **Limpeza:** `sudo nix-collect-garbage -d`
- **Atualizar Canais:** `sudo nix-channel --update`

## Padrões de Código

- **Imports:** Use listas explícitas: `imports = [ ./modules/hardware.nix ./modules/virtualization.nix ... ];`.
- **Comentários:** Comente em português explicando o "porquê" de configurações complexas (ex: flags de GPU ou opções do Zsh).
- **Pacotes:** Prefira `environment.systemPackages` para coisas globais (cli tools, drivers) e `home.packages` para coisas de uso pessoal (apps de produtividade, discord).

## O que NÃO fazer

- Não criar arquivos soltos na raiz sem permissão.
- Não usar comandos imperativos (`nix-env -i`) nas instruções; sempre use os arquivos `.nix`.
- Não esquecer de adicionar `nixpkgs.config.allowUnfree = true;` se adicionar software proprietário.

---

Se faltar informação sobre o hardware específico, assuma: Intel i5 8th Gen + GPU Híbrida AMD, 16GB RAM, SSD NVMe (conforme contexto anterior).