{...}: {
  programs.sway.enable = true;

  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sway.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.gtklock.enableGnomeKeyring = true;
}
