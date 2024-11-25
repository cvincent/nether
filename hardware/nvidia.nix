{
  config,
  pkgs,
  ...
}:

{
  # Load i915 module early to prevent Chromium/Electron apps from "GPU process
  # crashed" on boot in native Wayland
  boot.initrd.kernelModules = [ "i915" ];

  # Prevent issues on wake from DPMS
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    # TODO: Revisit these and ensure we're using everything we need but nothing
    # more. See: {https://nixos.wiki/wiki/Accelerated_Video_Playback}
    extraPackages = with pkgs; [
      vaapiVdpau
      nvidia-vaapi-driver
      intel-vaapi-driver
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = false;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # Use the freshest of fresh closed Nvidia driver
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "560.35.03";
      sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
      sha256_aarch64 = "";
      openSha256 = "";
      settingsSha256 = "";
      persistencedSha256 = "";

      # Copied from the NixOS Wiki, uncertain what it's for
      # patches = [ rcu_patch ];
    };
  };

  environment.sessionVariables = {
    # This allows vulkaninfo to give actual output...can also set to intel.
    # TODO: Figure this out, get chrome://gpu to report Vulkan enabled
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    __GL_VRR_ALLOWED = "1";
    __GL_GSYNC_ALLOWED = "1";
    # Not setting this to "nvidia" seems to crash Zoom tabs. Slack screensharing
    # is inconsistent, but seems to never crash if I start it via Terminal vs
    # Rofi. Looking forward to this shit being fully solved in Wayland on
    # Nvidia, someday...
    LIBVA_DRIVER_NAME = "nvidia";
    # Uncertain if this is needed, iirc "direct" is the default
    NVD_BACKEND = "direct";
  };
}
