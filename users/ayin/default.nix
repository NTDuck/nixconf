{ ... }:

{
  imports = [
    ../common  # default.nix
  ];

  programs.git.settings.user.name = "NTDuck";
  programs.git.settings.user.email = "nguyentuduck@gmail.com";
}
