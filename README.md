# Visão Geral da Configuração NixOS

Este repositório contém a configuração modular utilizada no meu notebook NixOS. A estrutura replica `/etc/nixos` e mantém cada componente (sistema, otimizações de hardware, ambiente do usuário) isolado para facilitar a manutenção.

## Estrutura de Diretórios

- `configuration.nix` – Ponto de entrada que importa hardware, programas e Home Manager.
- `hardware-configuration.nix` – Perfil de hardware gerado automaticamente pelo `nixos-generate-config`.
- `modules/`
  - `hardware-optimizations.nix` – Ajustes de GPU híbrida, firmware e energia para o notebook Intel + AMD.
  - `programs.nix` – Pacotes do sistema, Flatpak/Steam, virtualização e toolchains de desenvolvimento.
- `home.nix` – Configuração do Home Manager para o usuário `rocha` (Zsh + Oh My Zsh, Powerlevel10k, aliases e pacotes do usuário).

## Destaques

- KDE Plasma 6 com SDDM.
- Gráficos híbridos (Intel UHD 620 + AMD Radeon R5 M435) usando `amdgpu`, OpenGL e Vulkan.
- Steam habilitado, Flatpak com Zen Browser e virtualização via Podman/Libvirt.
- Tooling de desenvolvimento: toolchain Rust, bibliotecas Qt5 e dependências de build do projeto `catsout/wallpaper-engine-kde-plugin`.
- Home Manager para `rocha` com Zsh, Oh My Zsh, Powerlevel10k e aliases produtivos (`eza`, `bat`, etc.).

## Aplicar Mudanças

```sh
sudo nixos-rebuild switch
```

As alterações do Home Manager são aplicadas automaticamente via módulo NixOS. Se alterar somente o `home.nix`, é possível reconstruir de forma mais rápida com:

```sh
home-manager switch
```

## Atualizar o Pin do Home Manager

A configuração fixa o Home Manager no tarball `release-24.05`. Para atualizar, ajuste o URL do tarball em `configuration.nix` e reconstrua.
