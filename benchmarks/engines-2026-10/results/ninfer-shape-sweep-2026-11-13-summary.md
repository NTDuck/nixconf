# Sweep status 2026-11-13 05:30 (+07) — COMPLETE

## ninfer shape sweep (engine v0.17.2, 3090 24.5 GiB) — all in-repo models measured
| model | cells (ctx:C:tps@peak MiB) |
|---|---|
| qwen3.8-27b | 16k:8:155@21162, 32k:7:142@21154, 65k:6:128@21472, 131k:4:113@22010, 262k:1:97@23374 |
| qwen3.8-27b-turbo | 16k:8:116@19572, 32k:8:107@19870, 65k:8:100@20464, 131k:8:93@21654, 262k:5:70@23536 |
| bonsai2-27b | 16k:8:218@9706, 32k:8:169@10004, 65k:8:138@10598, 131k:8:116@11788, 262k:8:77@14168 |
| bonsai2-27b-abliterated | 16k:8:195@9706, 32k:8:161@10004, 65k:8:136@10598, 131k:8:106@11788, 262k:8:78@14168 |

Deferred (artifacts GC'd; recovery downloads in /tmp/ninfer-work): qwen3.8-27b-abliterated
(huihui bf16, 52/55.6 GB), qwen3.8-27b-coder390 (43/56 GB). SHAPES rows stay omitted until
converted + swept (CLI refuses unswept --context).

## Injected into modules/.../agentics/ninfer/default.nix
- SHAPES rows: measured C/peak + per-agent tps for the 4 models above.
- ninferShapeTable: display rows now carry (tps).
- Header: 2026-11-13 re-sweep note (v0.17.2, ±20 MiB peak agreement with 2026-11-11).
