{den, ...}: {
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    nixos = {config, ...}: {
      # Wi-Fi: Broadcom BCM43142 802.11b/g/n [14e4:4365] (2026-11-01):
      # Requires proprietary Broadcom STA (wl) driver; in-tree b43/brcmsmac do not
      # support 43142. broadcom-sta is permitted in central allowInsecurePredicate
      # (modules/features/system/nix/default.nix).
      #
      # Ethernet: Realtek RTL8111/8168/8411 PCI Express Gigabit Ethernet [10ec:8168] (rev 15):
      # In-tree r8169 driver works cleanly. Out-of-tree r8168 driver has known ASPM
      # and carrier detection bugs on this revision; blacklist r8168 explicitly.
      boot.kernelModules = ["wl" "r8169"];
      boot.blacklistedKernelModules = ["b43" "bcma" "brcmfmac" "brcmsmac" "r8168"];

      boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
    };
  };
}
