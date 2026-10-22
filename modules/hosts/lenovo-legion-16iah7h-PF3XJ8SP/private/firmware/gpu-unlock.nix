/*
   gpu-unlock (https://github.com/Zagitta/gpu-unlock) — pre-driver GA102
   BF16 Tensor Core unlock for the ADT-UT3G RTX 3090 eGPU.

   The kernel module is opt-in via kernel cmdline: without
   `gpu_unlock.targets=` it touches nothing, so keeping the module in the
   initrd is inert until the param is present. `targets=all` is safe here:
   the module matches by PCI device ID (GA102 0x220x-0x222f / GA104
   0x248x-0x24e0 GeForce/CMP only, main.c supported_ids[]), the laptop's
   RTX 3060 (GA106, 10de:2560) is absent from the table and is skipped.
   No BDF is hardcoded: the 3090's TB4 bus position (currently
   0000:06:00.0) can shift between boots.
*/
{
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: let
      version = "1.0.0";
      # Upstream HEAD 2026-10-21 "Add support me info" (tree 2f4c19d);
      # bb1088b added the remaining GA102/GA104 device ids.
      rev = "1799023e1d16dd1e58a7fc85823579fe93281e1a";
      src = pkgs.fetchzip {
        url = "https://github.com/Zagitta/gpu-unlock/archive/${rev}.tar.gz";
        hash = "sha256-cVEyS91D8Yex+uZfYG5MoANfIH6C/6dibaJ9GHF7rEk=";
      };

      # The unlock payload is NVIDIA-signed firmware (pinned to 610.43.03,
      # accepted by GA102 because NVIDIA never burned anti-rollback fuses
      # for that boot asset generation). Upstream does not ship binaries:
      # the V67 image is byte-generated (SHA-256 self-checked in
      # generate_v67.py), the booter/GSP-boot blobs are extracted from
      # NVIDIA's 610.43.03 open-kernel source and nvidia-utils package,
      # each against pinned hashes. gsp_ga10x.bin (84 MB) is the shared
      # GSP image the temporary SEC2 boot runs against.
      nv = "610.43.03";
      gpu-unlock-firmware = pkgs.runCommand "gpu-unlock-firmware-${version}"
        {
          # generate_v67.py decompresses the nvidia-utils .pkg.tar.zst
          # via the zstd CLI.
          nativeBuildInputs = [pkgs.zstd];
        }
        ''
        mkdir -p nvsrc assets
        tar -xf ${
          pkgs.fetchurl {
            url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-${nv}.tar.xz";
            sha256 = "7e118923c7a23edc36114d63273a46e3e04e9af98695a42203e7ac2dfe9fc1dc";
          }
        } -C nvsrc
        ${pkgs.python3.interpreter} ${src}/firmware/generate_v67.py ${
          pkgs.fetchurl {
            url = "https://archive.cachyos.org/archive/cachyos-v3/nvidia-utils-${nv}-1-x86_64_v3.pkg.tar.zst";
            sha256 = "e17e7c92eeffa178b0fe1f40eb17a47095f8fc3ce4a77bf115cf5bd5a4df86e9";
          }
        } assets
        ${pkgs.python3.interpreter} ${src}/firmware/extract_boot_assets.py nvsrc/NVIDIA-kernel-module-source-${nv} assets

        mkdir -p $out/lib/firmware/gpu-unlock/${nv}
        for f in booter_load_ga102.bin gsp_ga10x.bin gsp_boot_ga102.bin \
                 gsp_boot_desc_ga102.bin v67-ga102-${nv}.bin; do
          cp assets/$f $out/lib/firmware/gpu-unlock/${nv}/$f
        done
      '';

      kernel = config.boot.kernelPackages.kernel;

      gpu-unlock = pkgs.stdenv.mkDerivation {
        pname = "gpu-unlock";
        inherit version;

        inherit src;
        sourceRoot = "source/kernel/gpu_unlock";

        nativeBuildInputs = kernel.moduleBuildDependencies or [];
        # Upstream Makefile's `all` delegates: make -C "$(KDIR)" M="$(CURDIR)"
        # modules. kernel.makeFlags must NOT be forwarded — those are in-tree
        # flags (O=$(buildRoot) …) that break the delegation make.
        makeFlags = [
          "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        ];
        installPhase = ''
          runHook preInstall
          # NOT extra/: nvidia.ko (kernel/drivers/video/) reaches the initrd,
          # but every module installed under extra/ (gpu_unlock, lenovo_legion,
          # acpi_call) was silently dropped from the initrd copy list — the
          # stage-1 module resolution saw only paths inside kernel/. Installing
          # into the kernel/ subtree mirrors the nvidia out-of-tree precedent
          # and depmod indexes it identically.
          install -Dm644 gpu_unlock.ko \
            $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/misc/gpu_unlock.ko
          runHook postInstall
        '';

        passthru = {inherit gpu-unlock-firmware;};
        meta = with lib; {
          description = "Pre-driver GA102/GA104 BF16 Tensor Core unlock kernel module";
          homepage = "https://github.com/Zagitta/gpu-unlock";
          license = licenses.gpl2Only;
          platforms = ["x86_64-linux"];
        };
      };
    in {
      boot.extraModulePackages = [gpu-unlock];

      # Stage-1 order is the whole game: the scripted initrd loads
      # boot.initrd.kernelModules in list order BEFORE systemd-udevd /
      # udevadm trigger run (stage-1-init.sh), so gpu_unlock races
      # nothing — nvidia would fail its WPR2 check if it bound first.
      # mkBefore prepends in front of firmware/nvidia.nix's
      # ["nvidia" ...] without duplicating that list.
      boot.initrd.kernelModules = lib.mkBefore ["gpu_unlock"];

      # request_firmware() paths are hardcoded in unlock_610.c under
      # gpu-unlock/610.43.03/; extraFirmwarePaths copies them into the
      # initrd relative to ${hardware.firmware}/lib/firmware.
      hardware.firmware = [gpu-unlock-firmware];
      boot.initrd.extraFirmwarePaths = [
        "gpu-unlock/${nv}/booter_load_ga102.bin"
        "gpu-unlock/${nv}/v67-ga102-${nv}.bin"
        "gpu-unlock/${nv}/gsp_ga10x.bin"
        "gpu-unlock/${nv}/gsp_boot_ga102.bin"
        "gpu-unlock/${nv}/gsp_boot_desc_ga102.bin"
      ];

      boot.kernelParams = ["gpu_unlock.targets=all"];
    };
  };
}
