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
          "-device virtio-gpu-pci"
          # "-vga virtio"
          "-display sdl,gl=on,show-cursor=off"
          # Wire up pipewire audio
          # "-audiodev pipewire,id=audio0"
          # "-device audiodev=audio0"
          # "-device intel-hda"
          # "-device hda-output"
        ];

        environment.sessionVariables = {
          WLR_NO_HARDWARE_CURSORS = "1";
          WLR_RENDERER_ALLOW_SOFTWARE = "1";
        };

        nether.hardware.nvidia.enable = lib.mkForce false;
        nether.windowsVM.enable = lib.mkForce false;

        users.users."${config.nether.username}".initialPassword = lib.mkForce "testvm";
      };
    };
}
