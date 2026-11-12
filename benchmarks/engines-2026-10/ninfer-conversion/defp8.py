#!/usr/bin/env python3
"""Dequantize a vLLM-style fp8-block safetensors (<name>.weight + <name>.weight_scale_inv,
128x128 blocks) into plain BF16 safetensors so tools/convert's generic safetensors source
can read it. The converter then re-quantizes the draft to Q8 for the artifact (per recipe
_optional), so block-scale fidelity is preserved through bf16."""
import sys
from pathlib import Path
import torch
from safetensors.torch import load_file, save_file

src_dir, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
out_dir.mkdir(parents=True, exist_ok=True)
tensors = load_file(str(src_dir / "model.safetensors"))
out, scales_seen = {}, 0
for name, t in tensors.items():
    if name.endswith(".weight_scale_inv"):
        continue
    if name.endswith(".weight"):
        inv_name = name[: -len(".weight")] + ".weight_scale_inv"
    else:
        inv_name = None
    if inv_name and inv_name in tensors:
        inv = tensors[inv_name].to(torch.float32)
        h, w = t.shape
        bh, bw = inv.shape
        if h % bh or w % bw:
            raise ValueError(f"{name}: weight {h}x{w} not divisible by block grid {bh}x{bw}")
        expanded = inv.repeat_interleave(h // bh, dim=0).repeat_interleave(w // bw, dim=1)
        out[name] = (t.to(torch.float32) * expanded).to(torch.bfloat16)
        scales_seen += 1
    else:
        out[name] = t.to(torch.bfloat16) if t.dtype in (torch.float8_e4m3fn, torch.float16) else t
for extra in ("config.json", "manifest.json"):
    if (src_dir / extra).exists():
        (out_dir / extra).write_bytes((src_dir / extra).read_bytes())
save_file(out, str(out_dir / "model.safetensors"))
print(f"dequantized {len(out)} tensors ({scales_seen} fp8-block) -> {out_dir}")
