{
  pkgs,
  myUsername,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    virt-manager
    looking-glass-client
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  users.users."${myUsername}".extraGroups = [ "libvirtd" ];

  # Isolate the second dGPU
  boot = {
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"

      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];

    kernelParams = [
      "amd_iommu=on"
      "vfio-pci.ids=10de:1f08,10de:10f9,10de:1ada,10de:1adb"
    ];
  };

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 ${myUsername} libvirtd -"
  ];
}
