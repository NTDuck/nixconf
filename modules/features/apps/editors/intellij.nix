# IntelliJ IDEA (JetBrains, proprietary release — idea-oss is the abandoned
# community build, the memory-dump-level one died 2024; `idea` is the
# current UE/community artifact jetbrains ships via nixpkgs).
#
# Why an aspect instead of folding into dev.toolchains.java-kotlin: the
# toolchain aspect is the *JDK/build* set (maven/gradle/jdt-ls) that hosts
# include for headless dev; the IDE is session furniture and belongs to the
# app tree (same split as helix/zed/obsidian under apps.editors).
{den, ...}: {
  den.aspects.apps.editors.intellij = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.jetbrains.idea
      ];
    };
  };
}
