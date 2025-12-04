# Makefile de utilidades para NixOS em /etc/nixos

# Uso:
#   make backup   -> Backup do /etc/nixos
#   make sync     -> Sincroniza workspace -> /etc/nixos
#   make build    -> Compila configuração sem aplicar
#   make switch   -> Aplica configuração
#   make rollback -> Volta para geração anterior
#   make hm       -> Aplica Home Manager do usuário rocha
#   make test     -> Testes rápidos (GL/Vulkan)
#   make logs     -> Logs de erros recentes

ETC_NIXOS := /etc/nixos
CONFIG := $(ETC_NIXOS)/configuration.nix

SHELL := /usr/bin/env bash

.PHONY: backup sync build switch rollback hm test test-gl test-vk logs

backup:
	@set -euo pipefail; \
	TS=$$(date +%Y%m%d-%H%M); \
	echo "[backup] Salvando /etc/nixos em /etc/nixos.backup_$${TS}"; \
	sudo mkdir -p /etc/nixos.backup_$${TS}; \
	sudo cp -a $(ETC_NIXOS)/. /etc/nixos.backup_$${TS}/

sync:
	@set -euo pipefail; \
	echo "[sync] Sincronizando $(PWD) -> $(ETC_NIXOS)"; \
	sudo rsync -av --delete $(PWD)/ $(ETC_NIXOS)/

build:
	@set -euo pipefail; \
	echo "[build] nixos-rebuild build"; \
	sudo nixos-rebuild build -I nixos-config=$(CONFIG) --show-trace

switch:
	@set -euo pipefail; \
	echo "[switch] Aplicando configuração"; \
	sudo nixos-rebuild switch -I nixos-config=$(CONFIG) --show-trace

rollback:
	@set -euo pipefail; \
	echo "[rollback] Voltando para a geração anterior"; \
	sudo /run/current-system/sw/bin/nixos-rebuild switch --rollback

hm:
	@set -euo pipefail; \
	echo "[hm] Aplicando Home Manager para rocha"; \
	sudo -u rocha -H home-manager switch

test: test-gl test-vk

test-gl:
	@set -euo pipefail; \
	if ! command -v glxinfo >/dev/null; then \
		echo "[test-gl] glxinfo não encontrado. Instale 'mesa-demos'."; \
		exit 1; \
	fi; \
	echo "[test-gl] Renderer:"; \
	glxinfo | grep -i 'opengl renderer' || true

test-vk:
	@set -euo pipefail; \
	if ! command -v vulkaninfo >/dev/null; then \
		echo "[test-vk] vulkaninfo não encontrado. 'vulkan-tools' deve estar instalado."; \
		exit 1; \
	fi; \
	echo "[test-vk] GPUs detectadas:"; \
	vulkaninfo | grep -n "GPU id" || true

logs:
	@set -euo pipefail; \
	echo "[logs] Últimos erros do journal"; \
	journalctl -p err -b --no-pager || true; \
	echo; echo "[logs] Serviço Home Manager"; \
	journalctl -u home-manager-rocha.service -b --no-pager -n 200 || true
