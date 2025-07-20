{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      virtualisation.vmVariant = {
        virtualisation = {
          cores = 4;
          memorySize = 8192;
          diskSize = 5120;
        };

        virtualisation.qemu.options = [
          "-vga virtio"
          "-display sdl,gl=on,show-cursor=off"
          # Wire up pipewire audio
          # "-audiodev pipewire,id=audio0"
          # "-device audiodev=audio0"
          # "-device intel-hda"
          # "-device hda-output"
          # The following enables passthrough to our second GPU, just like our
          # Windows VM. However, it's only visible by switching our monitor to
          # the HDMI from the GPU. Further work would be needed to pass a
          # keyboard and mouse to it. There's no Looking Glass for a Linux
          # guest, as far as I know.
          # "-cpu max,kvm=off"
          # "-device vfio-pci,host=05:00.0,x-vga=on"
          # "-device vfio-pci,host=05:00.1"
          # "-device vfio-pci,host=05:00.2"
          # "-device vfio-pci,host=05:00.3"
          # "-vga none"
        ];

        # boot.kernelParams = [ "CONFIG_DRM_VIRTIO_GPU=1" ];

        # environment.sessionVariables = {
        #   WLR_NO_HARDWARE_CURSORS = "1";
        #   WLR_RENDERER_ALLOW_SOFTWARE = "1";
        # };

        # Guest does not need and won't build with the options we set up on the
        # host for the Windows VM
        nether.windowsVM.enable = lib.mkForce false;

        # Currently GDM doesn't start, possibly related to driver versions.
        # Might be able to re-enable when we're updated, and have our VM closer
        # to the physical configuration.
        nether.graphicalEnv.displayManager = lib.mkForce null;

        # Remove/comment this if using passthrough
        nether.hardware.nvidia.enable = lib.mkForce false;

        services.xserver.videoDrivers = [ "qxl" ];

        users.users."${config.nether.username}".initialPassword = lib.mkForce "testvm";

        # `virtualisation.fileSystems` gets overwritten, so we mount the backup
        # NFS this way instead. TODO: DRY this up
        boot.supportedFilesystems = [ "nfs" ];
        services.rpcbind.enable = true;

        systemd.mounts = [
          {
            type = "nfs";
            mountConfig = {
              Options = "noatime";
            };
            what = "192.168.1.128:/storage/smb";
            where = "/backup";
          }
        ];

        systemd.automounts = [
          {
            wantedBy = [ "multi-user.target" ];
            automountConfig = {
              TimeoutIdleSec = "600";
            };
            where = "/backup";
          }
        ];
      };
    };
}
