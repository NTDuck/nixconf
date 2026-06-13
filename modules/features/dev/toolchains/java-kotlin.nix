{
  den,
  inputs,
  ...
}: {
  den.aspects.javaKotlin = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.jdk21

        pkgs.unstable.maven
        pkgs.unstable.gradle

        pkgs.unstable.spring-boot-cli
        pkgs.unstable.jdt-language-server

        pkgs.unstable.jetbrains.idea-oss
      ];

      environment.sessionVariables = {
        JAVA_HOME = "${pkgs.unstable.jdk21.home}";
      };
    };
  };
}
