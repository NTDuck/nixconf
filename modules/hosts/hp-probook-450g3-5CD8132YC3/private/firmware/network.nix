{den, ...}: {
  den.aspects.hp-probook-450g3-5CD8132YC3.nixos = {
    # HP ProBook 450 G3 units commonly ship with Intel WLAN, which is handled
    # by the in-kernel iwlwifi driver and linux-firmware. Do not inherit the
    # Dell Latitude Broadcom STA setup here: it requires an out-of-tree module,
    # blacklists in-kernel Broadcom drivers, and adds an insecure-package
    # exception that this host should not need.
    boot.kernelModules = ["iwlwifi"];
  };
}
