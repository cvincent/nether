{ name, mkFeature, ... }:
mkFeature name (
  { pkgs, ... }:
  {
    toplevel.nvtop.package = pkgs.nvtopPackages.full;

    nixos = {
      # Prevent issues on wake from DPMS
      boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

      hardware.graphics = {
        enable = true;
        # TODO: Revisit these and ensure we're using everything we need but nothing
        # more. See: {https://nixos.wiki/wiki/Accelerated_Video_Playback}
        extraPackages = with pkgs; [
          libva-vdpau-driver
          nvidia-vaapi-driver
          libvdpau-va-gl
        ];
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = false;

        # prime = {
        #   offload = {
        #     enable = true;
        #     enableOffloadCmd = true;
        #   };
        #   intelBusId = "PCI:0:2:0";
        #   nvidiaBusId = "PCI:1:0:0";
        # };
      };

      environment.sessionVariables = {
        # This allows vulkaninfo to give actual output...can also set to intel.
        # TODO: Figure this out, get chrome://gpu to report Vulkan enabled
        VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
        __GL_VRR_ALLOWED = "1";
        __GL_GSYNC_ALLOWED = "1";
        LIBVA_DRIVER_NAME = "nvidia";
        # Uncertain if this is needed, iirc "direct" is the default
        NVD_BACKEND = "direct";
      };
    };
  }
)
