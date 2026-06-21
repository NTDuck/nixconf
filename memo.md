sudo nix --extra-experimental-features "nix-command flakes" run \'github:nix-community/disko/latest#disko-install\' -- --flake .#lenovo-legion-16iah7h-PF3XJ8SP --disk main /dev/nvme0n1

nixos-generate-config --no-filesystems --flake --dir .

lsblk
sudo mount -o subvol=persistent /dev/? /mnt
sudo cp ~/nixos/* /mnt/etc/nixos
