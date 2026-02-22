{ ... }:

{
  imports = [
    ../common  # default.nix
  ];

  programs.git.userName = "NTDuck";
  programs.git.userEmail = "nguyentuduck@gmail.com";
}
