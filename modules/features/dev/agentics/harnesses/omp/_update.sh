#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Fetching latest oh-my-pi release info..."
sums=$(curl -sL https://github.com/can1357/oh-my-pi/releases/latest/download/SHA256SUMS.txt)
tag=$(curl -sL -o /dev/null -w "%{url_effective}" https://github.com/can1357/oh-my-pi/releases/latest | sed 's|.*/tag/||')
version="${tag#v}"

hex_hash=$(echo "$sums" | grep -E '[0-9a-f]{64}[ \t]+omp-linux-x64' | awk '{print $1}')
if [ -z "$hex_hash" ]; then
  echo "Error: omp-linux-x64 not found in SHA256SUMS.txt" >&2
  exit 1
fi

sri_hash=$(nix hash to-sri --type sha256 "$hex_hash")

cat > _pin.json <<EOF
{
  "version": "$version",
  "hash": "$sri_hash"
}
EOF

echo "Successfully updated omp pin to $version ($sri_hash)"
