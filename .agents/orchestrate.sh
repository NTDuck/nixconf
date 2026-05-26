#!/usr/bin/env bash
find targets users -type f -name "*.nix" | xargs -P 100 -I {} python3 .agents/migrate.py {}
