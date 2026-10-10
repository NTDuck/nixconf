"""Engine registry + server lifecycle for the 3090 engine benchmark.

Each engine entry: how to START its OpenAI-compatible server on a unique
port, which model id to send, and how to STOP it. start() first clears
the 3090 (user pre-authorized killing any inference process), then
launches detached. GPU cleanliness invariant: exactly one engine server
holds VRAM while a cell runs; nothing else.
"""
import json, os, signal, subprocess, sys, time, urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
Q27 = Path("/home/ayin/models/q27-bench")
ASH = Q27 / "ashalliants/ninfer-rtx3090-linux-x64-0.15.0-rtx3090"
NALL = Path("/home/ayin/models/ninfer-bench/ninfer-all")
MODELS = Q27 / "models"
ENV = dict(os.environ, LD_LIBRARY_PATH="/run/opengl-driver/lib",
           CUDA_VISIBLE_DEVICES="GPU-a4e36250-873d-62c5-912e-fde18d238a6c")

ENGINES = {
    # ---------------- Bonsai 2 27B ----------------
    "q27-t3-mtp": {
        "model": "auto", "port": 8093,
        "cmd": ["env", "LD_LIBRARY_PATH=/run/opengl-driver/lib",
                "Q27_FIXED_STACK_GB=2.3", "Q27_BATCH=1",
                f"{Q27}/v0.14.4/q27-v0.14.4/q27-server-w8",
                f"{MODELS}/bonsai2-27b-t3-mtp-slim.q27",
                f"{MODELS}/qwen38-27b-mtp.tok",
                "--slots", "8", "--host", "127.0.0.1", "--port", "8093",
                "--think", "--think-budget", "0"],
    },
    "q27-t3-solo": {
        "model": "auto", "port": 8094,
        "cmd": ["env", "LD_LIBRARY_PATH=/run/opengl-driver/lib",
                "Q27_FIXED_STACK_GB=2.3", "Q27_BATCH=0",
                f"{Q27}/v0.14.4/q27-v0.14.4/q27-server-w8",
                f"{MODELS}/bonsai2-27b-t3-mtp-slim.q27",
                f"{MODELS}/qwen38-27b-mtp.tok",
                "--slots", "1", "--host", "127.0.0.1", "--port", "8094",
                "--think", "--think-budget", "0"],
    },
    "prism-ptq10": {
        "model": "auto", "port": 8095,
        "cmd": ["/run/current-system/sw/bin/bonsai-llama-server",
                "-m", "/nix/store/795fmdnyi2152j30b9z2w9z9qv8gi29r-bonsai2-27b-gguf/share/bonsai2/Ternary-Bonsai-2-27B-PTQ1_0.gguf",
                "-ngl", "99", "-fa", "on", "--jinja", "-c", "32768",
                "-np", "4", "--host", "127.0.0.1", "--port", "8095"],
    },
    # ---------------- Qwen3.8-27B ----------------
    "ninfer-all-b2": {
        # Container: oomd kills the default legacy prefix cache (8GiB pinned
        # host KV + 8 host-state slots inside a 15GiB-RAM host), so
        # --no-prefix-reuse is mandatory, not cosmetic.
        "model": "auto", "port": 8097, "container": True,
        "cmd": ["podman", "run", "--rm", "--security-opt", "label=disable",
                "--network", "host",
                "--device", "/dev/nvidia1", "--device", "/dev/nvidiactl",
                "--device", "/dev/nvidia-uvm",
                "-v", "/nix/store/3qixz64pvv7glvnhvqsib5fwb80rrfca-nvidia-x11-595.104.02/lib:/drv:ro",
                "-v", "/home/ayin/models/ninfer-bench/Ternary-Bonsai-2-27B-ninfer-v3.ninfer:/models/bonsai2.ninfer:ro",
                "-e", "LD_LIBRARY_PATH=/drv", "-e", "CUDA_VISIBLE_DEVICES=0",
                "--entrypoint", "/opt/ninfer/sm86/ninfer-serve",
                "ghcr.io/iamwavecut/ninfer-all:latest",
                "/models/bonsai2.ninfer", "--host", "0.0.0.0", "--port", "8097",
                "--max-context", "262144", "--kv-capacity", "262144",
                "--max-concurrency", "8", "--kv-dtype", "rk4v4",
                "--gdn-state-fp16", "--spec", "dflash2", "--draft-tokens", "5",
                "--no-prefix-reuse"],
    },
    "ninfer-061": {
        "model": "auto", "port": 8091,
        "cmd": ["/nix/store/4nc997j43rv42nx3k8zsdyxfsd48qb7v-ninfer-3090-0.6.1/bin/ninfer-serve",
                "/var/lib/ninfer/qwen3_8_27b.ninfer",
                "--host", "127.0.0.1", "--port", "8091",
                "--max-context", "65536", "--kv-capacity", "auto",
                "--max-concurrency", "8", "--max-pending-requests", "32",
                "--prefill-chunk", "1024", "--kv-dtype", "int8",
                "--spec", "mtp", "--draft-tokens", "3"],
    },
    "ashalliants-df2": {
        "model": "auto", "port": 8092,
        # ldd of the 0.15.0 binary needs 8 non-bundled libs; prism-llamacpp
        # covers cublas/cudart, nvidia-x11 covers libcuda, ffmpeg-full covers
        # av*/swscale, curl store path covers libcurl.
        "launcher": ["env",
                     "LD_LIBRARY_PATH=/nix/store/pck9wssp6ca6dfxhpz15c8p67z4r59bg-prism-llamacpp-libs/lib:/nix/store/3qixz64pvv7glvnhvqsib5fwb80rrfca-nvidia-x11-595.104.02/lib:/nix/store/rcz6a5zlg8vqx689qsxh1r4m8v3pn3ic-ffmpeg-full-6.1.6-lib/lib:/nix/store/cjxc4x3cnlzlcdrsi92k5i7pkn78ixnz-curl-8.21.0/lib",
                     f"{ASH}/run.sh", "qwen38-27b", "tuned"],
        "env": {"NINFER_SPEC": "dflash2", "NINFER_HOST": "127.0.0.1",
                "NINFER_PORT": "8092", "NINFER_FALLBACK": "off",
                "NINFER_HOST_STATE_SLOTS": "8",
                # Vendor run.sh pins 8 GiB host KV; shim clamps to 2 GiB
                # (oomd killed the sweep at 94% pressure, 2026-10-08).
                "NINFER_SERVER": f"{ASH}/ninfer-serve.hostkv-shim"},
    },
    "ashalliants-mtp": {
        "model": "auto", "port": 8096,
        "launcher": ["env",
                     "LD_LIBRARY_PATH=/nix/store/pck9wssp6ca6dfxhpz15c8p67z4r59bg-prism-llamacpp-libs/lib:/nix/store/3qixz64pvv7glvnhvqsib5fwb80rrfca-nvidia-x11-595.104.02/lib:/nix/store/rcz6a5zlg8vqx689qsxh1r4m8v3pn3ic-ffmpeg-full-6.1.6-lib/lib:/nix/store/cjxc4x3cnlzlcdrsi92k5i7pkn78ixnz-curl-8.21.0/lib",
                     f"{ASH}/run.sh", "qwen38-27b", "tuned"],
        "env": {"NINFER_SPEC": "mtp", "NINFER_HOST": "127.0.0.1",
                "NINFER_PORT": "8096", "NINFER_FALLBACK": "off",
                "NINFER_HOST_STATE_SLOTS": "8",
                "NINFER_SERVER": f"{ASH}/ninfer-serve.hostkv-shim"},
    },
    # ---------------- 2026-10-10 variant arm ----------------
    "swift-uncensored": {
        # Swift-Qwen3.8-27B-Uncensored (d0xin abliteration, wacomctl672
        # HF conversion) on the SAME 0.15.0 binary as the winner
        # baseline. The converted artifact is the 1124-object v2 flavor:
        # full MTP draft weights (16 bindings, identical to baseline)
        # but NO dflash2 draft weights (0 of baseline's 56 dflash2-bound
        # weights, 1.11 GiB) — the vendor converter never emitted the
        # dflash2 draft, so NINFER_SPEC=tuned/dflash2 is structurally
        # impossible and the engine rejects it ("Qwen3.5 config:
        # missing component dflash2", 2026-10-10 11:37). Run the mtp
        # lane instead: identical spec/profile to the ashalliants-mtp
        # arm, isolating the abliterated weights as the only variable.
        # run.sh MODEL="${NINFER_MODEL:-...}" takes the artifact
        # override; upgraded to v3 framing with the vendor
        # tools/upgrade_ninfer_v2_to_v3.py (weights preserved,
        # qwen3_8.jinja installed; sha256 of v2 source
        # 2b21316202d4cb6082625e1cd179f03b57d879cc72567063e48a6d5e744dc960,
        # 18210531328 B = upstream content-length).
        "model": "auto", "port": 8093,
        "launcher": ["env",
                     "LD_LIBRARY_PATH=/nix/store/pck9wssp6ca6dfxhpz15c8p67z4r59bg-prism-llamacpp-libs/lib:/nix/store/3qixz64pvv7glvnhvqsib5fwb80rrfca-nvidia-x11-595.104.02/lib:/nix/store/rcz6a5zlg8vqx689qsxh1r4m8v3pn3ic-ffmpeg-full-6.1.6-lib/lib:/nix/store/cjxc4x3cnlzlcdrsi92k5i7pkn78ixnz-curl-8.21.0/lib",
                     f"{ASH}/run.sh", "qwen38-27b", "tuned"],
        "env": {"NINFER_MODEL": f"{ASH}/models/swift_qwen3_8_27b_v3.ninfer",
                "NINFER_SPEC": "mtp", "NINFER_HOST": "127.0.0.1",
                "NINFER_PORT": "8093", "NINFER_FALLBACK": "off",
                "NINFER_HOST_STATE_SLOTS": "8",
                "NINFER_SERVER": f"{ASH}/ninfer-serve.hostkv-shim"},
    },
    # ---------------- 2026-10-09 additions (cand-scout#1/#2) ----------------
    "buun-qwen": {
        # spiritbuun/buun-llama-cpp @ b9637 (bc9340b9), source build.
        # SMOKE-VERIFIED 2026-10-09 on the 3090: loads IQ4_XS, serves,
        # TCQ accepted (-ctk turbo2_tcq -ctv turbo2_tcq; help lists
        # turbo2/3/4(_tcq)). Measured: -c 524288 -np 8 (8x65536 slots) =
        # 19682 MiB total incl. 13.6 GiB weights => ~12.2 KiB/tok TCQ KV.
        # Per-slot ceiling 65536: 131072/slot would need ~12.8 GiB KV +
        # weights > 24 GiB. Long window therefore [32768, 65536].
        "model": "auto", "port": 8098,
        "cmd": ["env", "LD_LIBRARY_PATH=/run/opengl-driver/lib",
                f"{Q27}/buun-llama-cpp/build/bin/llama-server",
                "-m", f"{MODELS}/Qwen3.8-27B-UD-IQ4_XS.gguf",
                "-ngl", "99", "-fa", "on", "--jinja",
                "--alias", "qwen38-27b-buun",
                "-c", "524288", "-np", "8",
                "-ctk", "turbo2_tcq", "-ctv", "turbo2_tcq",
                "--host", "127.0.0.1", "--port", "8098"],
    },
    "gguf-q4xs": {
        # Prism llama.cpp (bonsai-llama-server) on unsloth UD-IQ4_XS
        # (14.25 GiB, imatrix dynamic Q4; sha 40fac405...). First Qwen3.8
        # arm with an on-GPU-KV llama.cpp backend; qwen3_5 arch verified in
        # prism-b10685 sources (LLM_ARCH_QWEN35).
        "model": "auto", "port": 8099,
        # 2026-10-09 reboot: prism CUDA build moved into the DEFAULT
        # generation (specialisation/homelab no longer exists on
        # /run/current-system; /run/current-system/sw/bin/bonsai-llama-server
        # is the CUDA fork with cublas linked).
        "cmd": ["/run/current-system/sw/bin/bonsai-llama-server",
                "-m", f"{MODELS}/Qwen3.8-27B-UD-IQ4_XS.gguf",
                "-ngl", "99", "-fa", "on", "--jinja",
                "--alias", "qwen38-27b-gguf",
                # Per-slot = 32768; q8 KV (32 KiB/tok) so 32k x C8 fits:
                # 262144 x 32 KiB = 8 GiB + 14.25 GiB weights ~ 22.3 GiB.
                "-c", "262144", "-np", "8", "-ctk", "q8_0", "-ctv", "q8_0",
                "--host", "127.0.0.1", "--port", "8099"],
    },
}

VICTIMS = ["ninfer-serve", "q27-server", "llama-server", "vllm", "serve_openai",
           "sglang.launch_server"]


def clear_gpu():
    """Kill any inference holder on the 3090 (user pre-authorized), wait
    for VRAM to drain below 500 MiB used by compute apps."""
    out = subprocess.run(["nvidia-smi", "--query-compute-apps=pid,used_memory",
                          "--format=csv,noheader"], capture_output=True, text=True).stdout
    for line in out.strip().splitlines():
        if not line.strip():
            continue
        pid = int(line.split(",")[0])
        try:
            name = Path(f"/proc/{pid}/cmdline").read_bytes().split(b"\0")[0].decode()
        except Exception:
            continue
        if any(v in name for v in VICTIMS):
            subprocess.run(["kill", "-9", str(pid)])
    # Drain check scoped to the pinned 3090 (-i 1): other GPUs host the
    # user's desktop/games (e.g. GPU0 game at 2+ GiB) and must not fail
    # the assertion. Query returns "Unable to determine..." on missing
    # GPUs, so fall back to per-GPU index.
    for _ in range(60):
        out = subprocess.run(["nvidia-smi", "--query-compute-apps=used_memory",
                              "--format=csv,noheader", "-i", "1"],
                             capture_output=True, text=True).stdout
        if not out.strip() or all(
                not l.strip() or not l.split(",")[0].strip().split()[0].isdigit()
                or int(l.split(",")[0].strip().split()[0]) < 500
                for l in out.strip().splitlines() if l.strip()):
            return True
        time.sleep(1)
    return False


LOGD = ROOT / "server-logs"
LOGD.mkdir(exist_ok=True)


def get(tag):
    if tag not in ENGINES:
        sys.exit(f"unknown engine tag: {tag}")
    return dict(ENGINES[tag], tag=tag)


def start(cfg):
    """Clear GPU, launch server detached, wait until /v1/models 200s."""
    assert clear_gpu(), "GPU did not drain after killing holders"
    logf = open(LOGD / f"{cfg['tag']}.log", "ab")
    env = dict(ENV)
    env.update(cfg.get("env", {}))
    cmd = cfg.get("cmd") or cfg.get("launcher")
    if "launcher" in cfg:
        # run.sh is bash; env vars go through `env`
        cmd = cfg["launcher"]
    proc = subprocess.Popen(cmd, stdout=logf, stderr=subprocess.STDOUT,
                            stdin=subprocess.DEVNULL, env=env,
                            start_new_session=True)
    cfg["proc"] = proc
    deadline = time.time() + 900  # big artifacts load slowly
    while time.time() < deadline:
        if proc.poll() is not None:
            tail = (LOGD / f"{cfg['tag']}.log").read_text()[-1500:]
            raise RuntimeError(f"server {cfg['tag']} exited rc={proc.returncode}\n{tail}")
        try:
            r = urllib.request.urlopen(
                f"http://127.0.0.1:{cfg['port']}/v1/models", timeout=5)
            if r.status == 200:
                r.read(); r.close()
                return True
        except Exception:
            time.sleep(3)
    raise RuntimeError(f"server {cfg['tag']} never became healthy")


def stop(cfg):
    proc = cfg.get("proc")
    if proc and proc.poll() is None:
        proc.terminate()
        try:
            proc.wait(timeout=30)
        except subprocess.TimeoutExpired:
            proc.kill()
    clear_gpu()
