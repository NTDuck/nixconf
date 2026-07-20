{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.nixos = {pkgs, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-legion-16iah7h
    ];

    # hardware.opengl = {
    #   enable = true;
    #   driSupport = true;
    # };

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      nvidiaPersistenced = true;
      powerManagement.enable = true;
    };

    services.xserver.deviceSection = ''
      Option "Coolbits" "28"
    '';

    boot.initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

    environment.systemPackages = [
      pkgs.unstable.libva
      pkgs.unstable.libva-utils
      pkgs.unstable.libva-vdpau-driver
    ];

    environment.sessionVariables = {
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
    };
  };
}
