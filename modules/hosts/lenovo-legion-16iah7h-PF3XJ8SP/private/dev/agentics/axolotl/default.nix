# Axolotl (https://github.com/axolotl-ai-cloud/axolotl) — LLM fine-tuning
# trainer, added 2026-09-25 (user request). NOT in nixpkgs (the nixpkgs
# `axolotl` hits are python-axolotl/oldmemo — the Signal/OMEMO protocol
# packages, verified 2026-09-25; no upstream flake either). Strategy chosen
# by user (2026-09-25 ask): buildFHSEnv wrapping a hash-pinned uv venv —
# a pure-nixpkgs python3.withPackages cannot satisfy axolotl's ~50 exact
# pins (torch 2.13, transformers 5.x, trl 1.9, gradio 6, ...), and CUDA
# extensions (bitsandbytes/xformers/liger-kernel) ship as prebuilt wheels
# that expect an FHS layout.
#
# REPRODUCIBILITY CONTRACT: the venv installs from requirements.lock
# (committed next to this file, `uv pip compile --generate-hashes
# --python-version 3.12` against axolotl==0.19.0 + the PyTorch cu128
# index, 2026-09-25) with `--require-hashes` — uv refuses any wheel whose
# hash is not in the lock. The lock contains ONE local-version pin
# (torchao==0.17.0+cu128) that ONLY exists on the PyTorch cu128 index, so
# the install step must pass the same two-index setup the lock was
# compiled with (see the entry script below). torch 2.13.0 pulls the
# nvidia-*-cu13 pip wheels (self-contained CUDA runtime, no system CUDA
# toolkit needed); the FHS env supplies only the DRIVER userland
# (/run/opengl-driver -> libcuda.so) and /dev/nvidia* (built-in
# --dev-bind /dev /dev), which is what torch.cuda.is_available() actually
# requires. Host driver 595.99.02 (CUDA 13.x, live check 2026-09-25)
# satisfies the cu13 wheel runtime.
#
# Impurity boundary (accepted by the pinned-lock + FHS design): wheel
# bytes are pinned, but the pip/uv INSTALL step runs networked at build
# time against the PyPI index. A future fully-nix build (torchbin +
# callPackage of every dep) is the escape hatch if that ever bites.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, hotspot.nix pattern): training
    # gear lives inside specialisation.homelab with the rest of the 3090
    # stack.
    nixos = {pkgs, ...}: let
      lockFile = ./requirements.lock;

      axolotlFhs = pkgs.buildFHSEnv {
        name = "axolotl";
        # CUDA 13 wheel set (torch 2.13.0 + nvidia-*-cu13 pip wheels).
        targetPkgs = pkgs': with pkgs'; [
          uv
          git
          git-lfs
          # axolotl trains from local datasets and pushes to HF; git+ssh and
          # credential helpers come from the FHS closure.
          openssh
        ];
        # cu13 wheels dlopen libcuda.so.1 from the driver at runtime. bwrap
        # order matters: the auto-mount loop --binds the whole host /run
        # (rootfs has no /run entry of its own), and over-mounting the
        # driver ON TOP of a --bind /run fails with "oldroot ... No such
        # file or directory" (reproduced 2026-09-25 with a minimal bwrap
        # call; mount-over-bind refuses). Mounting a tmpfs on /run first
        # (wiping the host's runtime junk from inside the sandbox), then
        # binding the driver store path at the canonical location, works —
        # verified by the same minimal repro.
        extraBwrapArgs = [
          "--tmpfs /run"
          "--ro-bind /run/opengl-driver /run/opengl-driver"
          "--ro-bind /run/opengl-driver-32 /run/opengl-driver-32"
          # DNS inside the sandbox: /etc/resolv.conf -> /etc/static/resolv.conf
          # -> /run/systemd/resolve/stub-resolv.conf. The --tmpfs /run above
          # wipes the resolved stub dir, and glibc then falls back to
          # 127.0.0.1:53 (nothing listens there -> POLLERR -> "Temporary
          # failure in name resolution"; reproduced + verified by strace,
          # 2026-09-25). Re-bind the stub dir to close the chain.
          "--ro-bind /run/systemd/resolve /run/systemd/resolve"
        ];
        profile = ''
          export UV_CACHE_DIR=$HOME/.cache/axolotl-uv
          # torch.cuda.is_available() inside the sandbox needs, on the
          # loader path: libcuda.so.1 (driver userland) and libstdc++
          # (gcc runtime, NOT in the python3.12 closure). The cu13 wheel
          # libs resolve via their own rpath-relative layout inside the
          # venv, no entry needed here (verified: matmul on the 3090
          # ran with exactly this LD_LIBRARY_PATH, 2026-09-25).
          export LD_LIBRARY_PATH=/run/opengl-driver/lib:${pkgs.stdenv.cc.cc.lib}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
        '';
        runScript = pkgs.writeShellScript "axolotl-entry" ''
          set -eu
          # First invocation materialises the venv from the committed,
          # hash-pinned lock (uv verifies every wheel hash; network needed
          # once). Later invocations are no-ops (uv is content-addressed).
          if [ ! -x "$HOME/.axolotl-venv/bin/axolotl" ]; then
            echo "axolotl: materialising venv from hash-pinned requirements.lock (first run)..." >&2
            ${pkgs.uv}/bin/uv venv "$HOME/.axolotl-venv" --python ${pkgs.python312}/bin/python3.12
            ${pkgs.uv}/bin/uv pip install \
              --python "$HOME/.axolotl-venv/bin/python" \
              --require-hashes \
              --no-deps \
              --index-strategy unsafe-best-match \
              --index-url https://pypi.org/simple \
              --extra-index-url https://download.pytorch.org/whl/cu128 \
              -r ${lockFile}
            echo "axolotl: venv ready" >&2
          fi
          exec "$HOME/.axolotl-venv/bin/axolotl" "$@"
        '';
      };
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [axolotlFhs];
      }; # specialisation.homelab.configuration
    };
  };
}
