# Instruções de Operação (NixOS + VS Code)

Este documento orienta como aplicar, diagnosticar e melhorar sua configuração NixOS modular, além de habilitar o VS Code com acesso a `/etc`.

## Fluxo de Aplicação

1. Backup e sincronização para `/etc/nixos`:

```zsh
sudo mkdir -p /etc/nixos.backup_$(date +%Y%m%d-%H%M)
sudo cp -a /etc/nixos/. /etc/nixos.backup_$(date +%Y%m%d-%H%M)/
sudo rsync -av --delete /home/rocha/nixos/ /etc/nixos/
```

2. Reconstruir apontando para `/etc/nixos/configuration.nix`:

```zsh
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix --show-trace
```

4. Usando o Makefile (atalhos):

```zsh
# No diretório do repositório (/home/rocha/nixos)
make backup   # backup de /etc/nixos
make sync     # sincroniza -> /etc/nixos
make build    # compila sem aplicar
make switch   # aplica a configuração
make hm       # aplica Home Manager do usuário rocha
make test     # testa OpenGL/Vulkan rapidamente
make logs     # mostra logs úteis
```

3. Se falhar, colete o trace e procure opções inválidas ou pacotes removidos:

```zsh
tail -n +1 /var/log/nixos-rebuild.log 2>/dev/null || true
```

## Diagnóstico Rápido

- Procurar pacotes/atributos obsoletos:
```zsh
grep -R --line-number --color=always 'vaapiIntel\|amdvlk\|services.flatpak.packages' /home/rocha/nixos /etc/nixos || echo "nenhuma ocorrência"
```
- Verificar canal e versão do NixOS/Home Manager:
```zsh
nixos-version
nix --version
```

## VS Code com acesso a `/etc`

- Rodar VS Code com privilégios elevados (use com cuidado):
```zsh
sudo -E code --user-data-dir=/root/.vscode-root
```
- Alternativa mais segura: editar no `$HOME` e sincronizar com `rsync` como mostrado acima.
- Dica: Instale o plugin "Nix" e habilite formatação com `nixfmt`/`alejandra`.

## Testes Automatizados (Smoke Tests)

Crie um conjunto mínimo de verificações para garantir que opções fundamentais existem e não estão quebradas:

```zsh
# Verifica que módulos esperados existem
[ -f /etc/nixos/configuration.nix ] && echo OK configuration || echo FAIL configuration
[ -f /etc/nixos/modules/programs.nix ] && echo OK programs || echo FAIL programs
[ -f /etc/nixos/modules/hardware-optimizations.nix ] && echo OK hardware || echo FAIL hardware
[ -f /etc/nixos/home.nix ] && echo OK home || echo FAIL home

# Validação sintática básica de Nix
nix-instantiate /etc/nixos/configuration.nix --eval 2>/dev/null && echo OK nix || echo FAIL nix
```

Para testes mais fortes, use `nixos-rebuild build --show-trace` para compilar sem trocar o sistema.

Com o Makefile:
```zsh
make test      # executa checagens GL/Vulkan
./scripts/check_gpu.sh
```

## Melhorias Sugeridas

- Alinhar o pin do Home Manager com o seu NixOS (trocar para release-25.11) em `configuration.nix`.
- Adicionar `programs.direnv` + `nix-direnv` para ambientes de desenvolvimento.
- Incluir `nixpkgs.config.allowUnfree = true;` apenas no módulo de programas.
- Adicionar `zramSwap` e `fstrim.enable` para desempenho em notebook.

## Recuperação Rápida

Se algo quebrar após um switch, volte para a geração anterior:
```zsh
sudo /run/current-system/sw/bin/nixos-rebuild switch --rollback
```

Ou selecione a geração anterior no systemd-boot durante a inicialização.

## Notas Importantes

- O pacote `amdvlk` foi removido; RADV (Mesa) já fornece Vulkan por padrão.
- A API nova de gráficos é `hardware.graphics` (substitui `hardware.opengl`).
- A opção `services.flatpak.packages` não existe; para instalar apps Flatpak, use script de ativação (já incluído no `home.nix`).
