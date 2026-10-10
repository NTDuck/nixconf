#!/usr/bin/env .venv/bin/python
"""Expand a DFlash2-FP8 draft checkpoint (128x128 block-scale FP8) into a
plain-BF16 safetensors tree the converter can ingest natively.

Source: float8_e4m3fn `weight` + f32 `weight_scale_inv` grids [n/128, k/128].
Everything else copies through untouched. Without this, build_model dies
with "missing source tensor 'layers.0.*.weight_scale'" (2026-10-10): the
vendored converter's fp8_e4m3fn_row_bf16 import expects per-row scales,
but this checkpoint ships 128x128 block scales.
"""
import json
import shutil
import struct
import sys
from pathlib import Path

import torch


def main(src: Path, dst: Path) -> None:
    dst.mkdir(parents=True, exist_ok=True)
    model = src / "model.safetensors"
    with open(model, "rb") as f:
        hlen = struct.unpack("<Q", f.read(8))[0]
        hdr = json.loads(f.read(hlen))
    base = 8 + hlen

    out_header = {"__metadata__": {"note": "expanded block-FP8 -> BF16"}}
    chunks = []
    for key in (k for k in hdr if k != "__metadata__"):
        info = hdr[key]
        blob = torch.load  # noqa: F841 (placeholder removed below)
        del blob
        with open(model, "rb") as f:
            f.seek(base + info["data_offsets"][0])
            raw = f.read(info["data_offsets"][1] - info["data_offsets"][0])
        if key.endswith("_scale_inv"):
            continue  # folded into the FP8 partner below
        if info["dtype"] == "F8_E4M3":
            si = hdr[key + "_scale_inv"]
            with open(model, "rb") as f:
                f.seek(base + si["data_offsets"][0])
                scales = torch.frombuffer(
                    bytearray(f.read(si["data_offsets"][1] - si["data_offsets"][0])),
                    dtype=torch.float32,
                ).reshape(info["shape"][0] // 128, info["shape"][1] // 128)
            codes = torch.frombuffer(bytearray(raw), dtype=torch.uint8)
            values = codes.view(torch.float8_e4m3fn).to(torch.float32)
            values = values.view(info["shape"]).mul(
                scales.repeat_interleave(128, 0).repeat_interleave(128, 1)
            )
            payload = (
                values.to(torch.bfloat16).view(torch.uint16).numpy().tobytes()
            )
            out_header[key] = {
                "dtype": "BF16", "shape": info["shape"], "_sz": len(payload)
            }
        else:
            dtype = {
                "BF16": torch.bfloat16, "F32": torch.float32, "F64": torch.float64,
                "I8": torch.int8, "I32": torch.int32, "I64": torch.int64,
            }.get(info["dtype"])
            if dtype is None:
                raise SystemExit(f"unhandled dtype {info['dtype']} for {key}")
            out_header[key] = {
                "dtype": info["dtype"], "shape": info["shape"], "_sz": len(raw)
            }
            payload = raw
        out_header[key]["_payload"] = payload

    header = {"__metadata__": out_header.pop("__metadata__")}
    cursor = 0
    for key, info in out_header.items():
        header[key] = {
            "dtype": info["dtype"],
            "shape": info["shape"],
            "data_offsets": [cursor, cursor + info["_sz"]],
        }
        cursor += info["_sz"]

    hdr_bytes = json.dumps(header, separators=(",", ":")).encode()
    hdr_bytes += b" " * ((8 - len(hdr_bytes) % 8) % 8)
    with open(dst / "model.safetensors", "wb") as f:
        f.write(struct.pack("<Q", len(hdr_bytes)))
        f.write(hdr_bytes)
        for info in out_header.values():
            f.write(info["_payload"])

    for fname in ("config.json", "manifest.json"):
        if (src / fname).exists():
            shutil.copy(src / fname, dst / fname)


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
