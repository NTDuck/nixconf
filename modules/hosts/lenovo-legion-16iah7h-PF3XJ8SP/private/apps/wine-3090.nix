{
  den,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # 3090-pinned wine launchers — HOMELAB-ONLY (2026-09-21 user request,
    # 3090 specialisation pattern). Moved out of the shared apps.gaming.wine aspect:
    # the wrappers force the docked RTX 3090 by device name, meaningless
    # without the tunnel.
    nixos = {
      pkgs,
      ...
    }: {
      specialisation.homelab.configuration.environment.systemPackages = let
        # DXVK/VKD3D route Vulkan by device; without a filter wine lands on
        # the first enumerated GPU (the laptop 3060) and games render there
        # while the 3090 idles. The filters force the docked RTX 3090.
        gpuFilters = ''
          export DXVK_FILTER_DEVICE_NAME="NVIDIA GeForce RTX 3090"
          export VKD3D_FILTER_DEVICE_NAME="NVIDIA GeForce RTX 3090"
        '';
      in [
        # wine's wgl follows the GLX vendor: force NVIDIA (the host-wide
        # __GLX_VENDOR_LIBRARY_NAME in firmware/nvidia.nix covers X11
        # sessions; this wrapper makes the wow64/X11 launcher robust in
        # bare environments too).
        (pkgs.writeShellScriptBin "wine3090" ''
          ${gpuFilters}
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          exec "${pkgs.unstable.wineWow64Packages.stableFull}/bin/wine" "$@"
        '')
        (pkgs.writeShellScriptBin "wine3090-wayland" ''
          ${gpuFilters}
          exec "${pkgs.unstable.wine-wayland}/bin/wine" "$@"
        '')
      ];
    };
  };
}
