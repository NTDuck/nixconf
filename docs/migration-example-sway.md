# Sway Migration Example

This document demonstrates how to migrate the existing Sway configuration to the dendritic pattern. Currently, the Sway configuration is split across two files:
- System: `targets/common/sway.nix`
- User: `users/common/sway.nix`

In the dendritic pattern, we combine these into a single feature file: `den/modules/features/sway.nix`.

## `den/modules/features/sway.nix`

```nix
{ inputs, pkgs, ... }:
let
  # Shared variables can be defined here, avoiding the need for `specialArgs`
  # across NixOS and Home Manager contexts.
  modifier = "Mod4";
in {
  # The NixOS aspect of the Sway feature
  flake.modules.nixos.sway = {
    programs.sway.enable = true;
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    programs.dconf.enable = true;
    security.pam.services.sway.enableGnomeKeyring = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    security.pam.services.gtklock.enableGnomeKeyring = true;
  };

  # The Home Manager aspect of the Sway feature
  flake.modules.homeManager.sway = {
    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.sway;
      systemd.enable = true;
      xwayland = true;
      wrapperFeatures.gtk = true;
      
      config = {
        inherit modifier;
        
        terminal = "${pkgs.foot}/bin/footclient";
        menu = "${pkgs.tofi}/bin/tofi-drun --drun-launch=true";
        bars = [ { command = "${pkgs.waybar}/bin/waybar"; } ];
        
        startup = [
          { command = "fcitx5 -d -r"; always = true; }
          { command = "${pkgs.autotiling-rs}/bin/autotiling-rs"; always = true; }
          { command = "dbus-update-activation-environment --systemd --all; systemctl --user import-environment"; always = true; }
        ];

        # ... other keybindings, inputs, gaps, and window rules migrated directly
        # from users/common/sway.nix ...
      };
    };

    services.swayidle = {
      enable = true;
      package = pkgs.swayidle;
      events = [
        { event = "before-sleep"; command = "${pkgs.gtklock}/bin/gtklock"; }
        { event = "after-resume"; command = "swaymsg 'output * dpms on'"; }
      ];
    };

    stylix.targets.fcitx5.enable = true;
  };
}
```

### Benefits of this Migration

1. **Context Colocation:** Anyone debugging the Sway environment only has to look in one file. Both system prerequisites (PAM, polkit) and user setup (keybindings) are immediately visible.
2. **Simplified Imports:** A host simply needs to import the relevant `flake.modules` aspects (or just activate the overarching system type that pulls in this feature) without manually traversing `targets/` and `users/` trees.
3. **Shared Context:** We can share variables like `modifier` between NixOS and Home Manager natively through lexical scope.
