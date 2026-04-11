{
  inputs,
  system,
  ...
}: {
  home.packages = [
    inputs.cursor.packages.${system}.cursor
  ];
}
