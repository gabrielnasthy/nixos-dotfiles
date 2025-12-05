{ config, lib, pkgs, ... }:

# Módulo de usuários do sistema
# Por quê: centraliza definição de usuário principal e integra com Home Manager.

let
  username = "rocha";
in
{
  options.usersMain.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Habilita configuração do usuário principal e Home Manager.";
  };

  config = lib.mkIf config.usersMain.enable {
    users.users.${username} = {
      isNormalUser = true;
      description = "Gabriel Aguiar Rocha";
      shell = pkgs.zsh; # Zsh como shell padrão
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    };

    # Integração com Home Manager como módulo do NixOS
    home-manager.users.${username} = import ../home.nix;
  };
}
