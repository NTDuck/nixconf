{inputs, ...}: {
  systems = ["x86_64-linux" "aarch64-linux"];

  imports = [
    inputs.flake-parts.flakeModules.modules
  ];
}
