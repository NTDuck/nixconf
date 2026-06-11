{inputs, ...}: {
  imports = [
    inputs.flake-file.flakeModules.default
    inputs.den.flakeModules.default
  ];
}
