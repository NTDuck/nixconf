git clone https://github.com/NTDuck/nixconf

sudo nixos-generate-config --show-hardware-config > ./targets/dell-latitude-E7270-H836QF2/hardware.nix
sudo nix --extra-experimental-features "nix-command flakes" run \'github:nix-community/disko/latest#disko-install\' -- --flake .#lenovo-legion-16iah7h-PF3XJ8SP --disk main /dev/nvme0n1
nixos-generate-config --no-filesystems --flake --dir .

lsblk # to determine nvme0n1pX
sudo mount -o subvol=persistent /dev/nvme0n1pX /mnt
sudo cp ~/nixconf/* /mnt/etc/nixconf
