{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  # Radeon R5 M435 geralmente usa o driver radeon (não amdgpu)
  services.xserver.videoDrivers = [ "modesetting" "radeon" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva
      libvdpau-va-gl
      vulkan-loader
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
      libva
      libvdpau-va-gl
      vulkan-loader
    ];
  };
}
