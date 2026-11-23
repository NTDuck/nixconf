{den, ...}: {
  den.aspects.system.nix.nh = {
    nixos = {pkgs, ...}: {
      programs.nh = {
        enable = true;
        # 2026-11-23: nh 4.5.0 passes systemd-run --output=cat, which requires
        # systemd 261. NixOS currently runs systemd 260, which rejects this flag.
        # Upstream fix probes systemd version; until that is packaged, patch nh
        # to fall back to --pipe. Cargo.lock is untouched so cargoHash is unchanged.
        package = pkgs.unstable.nh.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace crates/nh-remote/src/remote.rs \
              --replace-fail '"--output=cat",' '"--pipe",'
          '';
        });

        clean = {
          enable = true;
          dates = "daily";
          # 2026-09-14: --keep-since 4d kept every generation because heavy
          # iteration produced 27 system gens inside 4d, so the daily job
          # freed nothing from profiles. 1d + keep 5 actually reclaims; the
          # journal (daily 2-50 GiB freed) showed the timer itself was fine.
          extraArgs = "--keep-since 1d --keep 5 --optimise";
        };
      };
    };
  };
}
