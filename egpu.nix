{ config, pkgs, ... }:
# https://dataswamp.org/~solene/2021-12-05-nixos-egpu.html
# https://y.tsutsumi.io/2020/08/15/egpu-linux-core-x-chroma/
# https://www.protondb.com/app/2519830
# __GLX_VENDOR_LIBRARY_NAME=nvidia __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json %command%
{
  environment.variables = {
    "__NV_PRIME_RENDER_OFFLOAD" = "1";
    "__VK_LAYER_NV_optimus" = "NVIDIA_only";
    "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
    "DRI_PRIME" = "1";
  };
  hardware.graphics.extraPackages = with pkgs; [ monado-vulkan-layers ];
  hardware.graphics.extraPackages32 = with pkgs; [ monado-vulkan-layers ];
  services.wivrn = {
    enable = true;
    defaultRuntime = true;
    autoStart = true;
    openFirewall = true;
  };
  environment.systemPackages = with pkgs; [
    mesa-demos
    intel-gpu-tools
    nvtop
  ];
  services.hardware.bolt.enable = true;
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    # Use Nvidia Prime to choose which GPU (iGPU or eGPU) to use.
    prime = {
      offload.enable = true;
      #sync.enable = true;
      allowExternalGpu = true;

      # Make sure to use the correct Bus ID values for your system!
      nvidiaBusId = "PCI:9:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };
}
