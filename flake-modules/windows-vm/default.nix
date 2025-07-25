{ name }:
{ lib, moduleWithSystem, ... }:
{
  # TODO: Most of this is actually setting up GPU passthrough, which isn't
  # necessarily only used by the Windows VM; it's also possible to pass the GPU
  # through to other guests, such as `build-vm`, which we configure in
  # `build-vm.nix`. So we could probably split the modules a bit better.
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    {
      options = {
        nether.windowsVM.enable = lib.mkEnableOption "Windows VM for use with Looking Glass";
      };

      config = lib.mkIf config.nether.windowsVM.enable {
        environment.systemPackages = with pkgs; [
          virt-manager
          looking-glass-client
        ];

        nether.backups.paths."/var/lib/libvirt/images" = { };

        virtualisation.libvirtd = {
          enable = true;
          qemu.ovmf.enable = true;
          onBoot = "ignore";
          onShutdown = "shutdown";
        };

        virtualisation.spiceUSBRedirection.enable = true;
        programs.virt-manager.enable = true;

        users.users."${config.nether.username}".extraGroups = [ "libvirtd" ];

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
          "f /dev/shm/looking-glass 0660 ${config.nether.username} libvirtd -"
        ];
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.windowsVM.enable {
        dconf.settings = {
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = [ "qemu:///system" ];
            uris = [ "qemu:///system" ];
          };
        };
      };
    };
}
