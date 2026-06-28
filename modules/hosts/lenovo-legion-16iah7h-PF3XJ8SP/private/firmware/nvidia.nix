{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users = {user, ...}: {
    nixos = {pkgs, ...}: {
      imports = [
        inputs.nixos-hardware.nixosModules.lenovo-legion-16iah7h
      ];

      hardware.opengl = {
        enable = true;
        driSupport = true;
      };

      hardware.nvidia = {
        modesetting.enable = true;
        nvidiaSettings = true;
      };

      boot.initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
      boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

      environment.systemPackages = [
        pkgs.unstable.libva
        pkgs.unstable.libva-utils
        pkgs.unstable.libva-nvidia-driver
      ];
    };
  };
}
