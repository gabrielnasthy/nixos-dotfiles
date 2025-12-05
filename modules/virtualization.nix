{ config, lib, pkgs, ... }:

# Módulo de Virtualização (KVM/QEMU + Libvirt + Virt-Manager)
# Por quê: habilita hypervisor KVM com gerenciamento via libvirtd e UI do virt-manager.
# Foco em desktop: aceleração por KVM, rede NAT padrão, e permissões de usuário.

let
  cfg = config.virtualization;
in
{
  options.virtualization = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Habilita stack de virtualização baseada em KVM/libvirt.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Kernel: garante módulos necessários para KVM (Intel/AMD)
    boot.extraModulePackages = [ ];

    # Libvirt (daemon de virtualização)
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        # Usar QEMU com KVM (aceleração hardware)
        package = pkgs.qemu_kvm;
        # Habilita suporte a vídeo/USB úteis em desktop
        # Observação: spice e USB redirection dependem de pacotes do host.
        swtpm.enable = true; # TPM virtual para VMs modernas
      };
      # Rede NAT padrão (virbr0). Mantém simples para desktop.
      # libvirt por padrão cria uma rede default; ajustes finos podem ser adicionados se necessário.
    };

    # Virt-Manager (UI)
    programs.virt-manager.enable = true;

    # Pacotes úteis para virtualização (guest tools, spice, usb redirection)
    environment.systemPackages = with pkgs; [
      virtio-win            # drivers para VMs Windows
      spice-gtk             # SPICE display/clipboard
      usbredir              # redirecionamento USB para VMs
      OVMF                  # UEFI firmware para VMs (substitui edk2-ovmf)
    ];

    # Permissões/grupos: usuários em 'libvirtd' podem gerenciar VMs
    users.groups.libvirtd.members = lib.optional (config.users.users ? rocha) "rocha";

    # TPM para VMs é fornecido via `virtualisation.libvirtd.qemu.swtpm.enable = true;`
    # Não há opção `services.swTPM` no NixOS; removido para compatibilidade.
  };
}
