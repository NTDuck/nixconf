{den, ...}: {
  den.aspects.dev.toolchains = {
    includes = [
      den.aspects.dev.toolchains.android
      den.aspects.dev.toolchains.c-cpp
      den.aspects.dev.toolchains.go
      den.aspects.dev.toolchains.java-kotlin
      den.aspects.dev.toolchains.javascript-typescript
      den.aspects.dev.toolchains.lua
      den.aspects.dev.toolchains.nix
      den.aspects.dev.toolchains.protobuf
      den.aspects.dev.toolchains.python
      den.aspects.dev.toolchains.rust
      den.aspects.dev.toolchains.topiary
    ];
  };
}
