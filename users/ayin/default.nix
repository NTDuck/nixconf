{ ... }:

{
  imports = [
    ../common  # default.nix
  ];

  programs.git.settings.userName = "NTDuck";
  programs.git.settings.userEmail = "nguyentuduck@gmail.com";
}
