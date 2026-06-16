{den, ...}: {
  den.aspects.toolchains = {
    includes = [
      den.aspects.c-cpp
      den.aspects.docker
      den.aspects.java-kotlin
      den.aspects.javascript-typescript
      den.aspects.lua
      den.aspects.nix
      den.aspects.protobuf
      den.aspects.python
      den.aspects.rust
      den.aspects.topiary
    ];
  };
}
