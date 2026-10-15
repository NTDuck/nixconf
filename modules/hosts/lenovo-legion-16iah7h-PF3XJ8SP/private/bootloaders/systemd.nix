{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {config, ...}: {
      # Always pin the default boot entry to the latest homelab specialisation generation.
      # systemd-boot supports glob patterns in loader.conf 'default' field and picks the
      # newest matching version (nixos-generation-<highest>-specialisation-homelab.conf).
      boot.loader.systemd-boot.extraInstallCommands = ''
        esp="${config.boot.loader.efi.efiSysMountPoint}"
        conf="$esp/loader/loader.conf"
        if [ -f "$conf" ] && ls "$esp/loader/entries"/nixos-*-specialisation-homelab.conf >/dev/null 2>&1; then
          sed -i -E 's/^default .*/default nixos-*-specialisation-homelab.conf/' "$conf"
        fi
      '';
    };
  };
}
