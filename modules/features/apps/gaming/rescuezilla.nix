{
  # rescuezilla (https://github.com/rescuezilla/rescuezilla) — Clonezilla-
  # compatible graphical disk backup/restore. Legion-only.
  #
  # NOT in nixpkgs (verified 2026-11-15 against locked 26.05, unstable and
  # master; upstream never merged a NixOS packaging request). Upstream ships
  # a bootable Ubuntu ISO and an architecture-independent .deb of pure
  # Python3/GTK code; this aspect packages the 2.6.2 .deb natively.
  #
  # Layout of the .deb: /usr/sbin/rescuezilla (sh wrapper: single-instance
  # check, pkexec to root, udisks/hal automount inhibition best-effort),
  # /usr/sbin/rescuezillapy (python entry), the python package in
  # /usr/lib/python3/dist-packages/rescuezilla, /usr/share/rescuezilla
  # (glade UI + version files, hard-coded absolute paths), locales,
  # .desktop, pixmaps, and a polkit action for root escalation.
  #
  # Known gaps after porting (verified against 2.6.2 sources, all degrade
  # gracefully — core backup/restore/verify/clone are unaffected):
  #   - Image Explorer (beta, browse-inside-image) needs `nbdkit` +
  #     `partclone-nbd`. nbdkit is provided; partclone-nbd is a separate
  #     Debian package not in nixpkgs, so that one wizard feature errors
  #     with a clear message at its step.
  #   - `ocs-*` Clonezilla helper scripts (GRUB/syslinux/initrd
  #     postprocessing) and `update-efi-nvram-boot-entry` are absent →
  #     skipped with log messages; EFI boot entries can be restored
  #     manually via efibootmgr.
  #   - reiserfs grow (resize_reiserfs) removed from nixpkgs 2024 →
  #     reiserfs resize reports "not found". Imaging/restoring reiserfs
  #     still works via partclone.
  #   - udisks2-inhibit is not shipped by nixpkgs udisks2; the wrapper
  #     falls back to plain launch (automount inhibition relies on the
  #     polkit root context instead).
  den.aspects.apps.gaming.rescuezilla = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      version = "2.6.2";
      deb = pkgs.fetchurl {
        url = "https://github.com/rescuezilla/rescuezilla/releases/download/v${version}/rescuezilla_${version}-1_all.deb";
        hash = "sha256-Wpe3lmD2RGYvahYIB0PsH1466AqopqYCN3qiKYLBhCs=";
      };

      # Python env: only the imports the code actually makes (requirements.txt
      # lists vext/pkg-resources/ruamel/pytz, but no module imports them —
      # verified by AST scan of every .py in the package). PyGObject pulls
      # in gi; Gtk-3.0 typelibs are supplied at runtime by GI_TYPELIB_PATH
      # (gtkTypelibPath below) — gtk3 is NOT in the python package set
      # (ps.gtk3 does not exist, verified 2026-11-15).
      pythonEnv = pkgs.python3.withPackages (ps: with ps; [
        pygobject3
        pycairo
        babel
      ]);
      # Gtk-3.0 typelibs + everything its namespace requires at runtime.
      # lib.getLib is required: pango/glib default to their `bin` output,
      # which carries no lib/girepository-1.0 (verified 2026-11-15).
      # harfbuzz is the inverse: getLib resolves to its -dev output (no
      # typelib); HarfBuzz-0.0.typelib ships in `out`.
      gtkTypelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0" [
        pkgs.gtk3
        (pkgs.lib.getLib pkgs.pango)
        (pkgs.lib.getLib pkgs.gdk-pixbuf)
        (pkgs.lib.getLib pkgs.glib)
        (pkgs.lib.getLib pkgs.at-spi2-core)
        (pkgs.lib.getLib pkgs.gobject-introspection)
        (pkgs.lib.getOutput "out" pkgs.harfbuzz)
      ];

      # Every external command the python code and wrapper can invoke.
      # AST-extracted from all subprocess/which call sites in 2.6.2; see
      # per-package note for graceful-degradation gaps above.
      cliTools = with pkgs; [
        # core imaging
        partclone
        partclone-utils
        partimage
        fsarchiver
        # partition/FS query + repair
        util-linux # lsblk blkid findmnt hexdump mkswap partx blockdev wipefs sfdisk
        parted # parted partprobe
        gptfdisk # sgdisk
        e2fsprogs # e2fsck resize2fs
        dosfstools
        fatresize
        ntfs3g # ntfsfix ntfsresize ntfsclone ntfscp ntfsinfo
        btrfs-progs
        xfsprogs # xfs_growfs
        f2fs-tools
        jfsutils
        nilfs-utils # nilfs-resize
        mdadm
        lvm2 # vgscan vgchange pvcreate lv* vgs pvs
        multipath-tools # kpartx
        # disk info
        smartmontools
        hdparm
        dmidecode
        lshw
        pciutils # lspci
        efibootmgr
        # hashing/verify
        coreutils # cat dd sync shred sha512sum sort split
        # compression (decompress chain via pigz/pbzip2/... exactly as mapped
        # in utility.get_decompression_command_list)
        gzip
        pigz
        pbzip2
        bzip2
        lzop
        xz # unlzma unxz
        plzip
        lrzip
        lz4 # unlz4
        zstd
        pv
        # network mount paths (SSH/SMB/NFS wizards)
        sshfs
        sshpass
        cifs-utils # mount.cifs
        nfs-utils # mount.nfs
        samba # smbclient
        rsync
        # image explorer (beta): nbdkit present, partclone-nbd absent (see header)
        nbdkit
        nbd # nbd-client
        qemu-utils # qemu-img qemu-nbd (virtual disk images)
        archivemount
        # misc
        file
        yad # wrapper fallback error dialogs when not launched from terminal
        os-prober
        psmisc # pkill/fuser
        kmod # modprobe lsmod modinfo
        which
        gettext # env/localization helpers
        chntpw # windows registry handling in images
        # wrapper script expectations
        polkit # pkexec (bin output)
        systemd # shutdown reboot systemctl mask/unmask
        udisks2 # presence for HAVE_UDISKS checks (inhibit helper absent)
        xhost # wayland/x11 root display workaround path
        libnotify # notify-send availability for the app
      ];

      pathPrefix = pkgs.lib.makeBinPath cliTools;

      rescuezilla = pkgs.stdenv.mkDerivation {
        pname = "rescuezilla";
        inherit version;

        src = deb;

        nativeBuildInputs = [pkgs.dpkg pkgs.makeWrapper];

        dontStrip = true;
        dontPatchELF = true;
        dontAutoPatchelf = true;

        unpackPhase = ''
          dpkg-deb -x $src ./out
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r ./out/* $out/
          chmod -R u+w $out
          runHook postInstall
        '';

        postFixup = ''
          # The sh wrapper calls /usr/sbin/rescuezillapy by absolute path.
          substituteInPlace $out/usr/sbin/rescuezilla \
            --replace-fail '/usr/sbin/rescuezillapy' "$out/usr/sbin/rescuezillapy"

          # The python entry hard-codes the glade file path and shebang.
          substituteInPlace $out/usr/sbin/rescuezillapy \
            --replace-fail '#!/usr/bin/python3' '#!${pythonEnv}/bin/python3' \
            --replace-fail '/usr/share/rescuezilla/rescuezilla.glade' "$out/usr/share/rescuezilla/rescuezilla.glade"

          # polkit action must point at the real, wrapped entry (pkexec
          # refuses relative paths and the /usr path does not exist).
          substituteInPlace $out/usr/share/polkit-1/actions/com.rescuezilla.rescuezilla.policy \
            --replace-fail '/usr/sbin/rescuezilla' "$out/usr/sbin/rescuezilla"

          # Desktop entry Exec likewise.
          substituteInPlace $out/usr/share/applications/rescuezilla.desktop \
            --replace-fail 'Exec=/usr/sbin/rescuezilla' "Exec=$out/usr/sbin/rescuezilla"

          # Both entries need the CLI toolbelt on PATH; the python entry
          # additionally needs its dist-packages import path and the Gtk-3.0
          # typelibs (pygobject's wrapped gi picks up typelibs from the
          # env's own GI_TYPELIB_PATH, which the gtk3 wheel adds).
          wrapProgram $out/usr/sbin/rescuezillapy \
            --set PYTHONPATH "$out/usr/lib/python3/dist-packages:${pythonEnv}/lib/python3.13/site-packages" \
            --prefix GI_TYPELIB_PATH : ${gtkTypelibPath} \
            --prefix PATH : ${pathPrefix}

          wrapProgram $out/usr/sbin/rescuezilla \
            --prefix PATH : ${pathPrefix}

          mkdir -p $out/bin
          ln -s ../usr/sbin/rescuezilla $out/bin/rescuezilla
        '';

        meta = {
          description = "Graphical hard drive backup and restore (Clonezilla compatible)";
          homepage = "https://rescuezilla.com";
          license = lib.licenses.gpl3Plus;
          mainProgram = "rescuezilla";
          platforms = ["x86_64-linux"];
        };
      };
    in {
      environment.systemPackages = [rescuezilla];

      # Rescuezilla needs the nbd kernel module for its Image Explorer and
      # partclone restore paths; load it at boot (upstream suggests /etc/modules).
      boot.kernelModules = ["nbd"];
    };
  };
}
