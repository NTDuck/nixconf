# Disable registering the ~ key (scancode 0x29 / KEY_GRAVE):
# Prevents ghost/stuck key events when the lid is closed or from physical keyboard fault.
# Mapped to KEY_RESERVED via udev hwdb so the Linux kernel input layer drops events.
{
  ...
}: {
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    nixos = {
      services.udev.extraHwdb = ''
        # HP ProBook internal AT keyboard (scancode 0x29 -> reserved)
        evdev:atkbd:dmi:*
         KEYBOARD_KEY_29=reserved

        # Generic USB / HID keyboard (usage 0x70035 -> reserved)
        evdev:input:b*v*p*
         KEYBOARD_KEY_70035=reserved
      '';
    };
  };
}
