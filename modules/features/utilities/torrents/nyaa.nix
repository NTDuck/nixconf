{
  den,
  inputs,
  ...
}: {
  den.aspects.utilities.torrents.nyaa = {
    homeManager = {
      imports = [
        inputs.nyaa.homeManagerModule
      ];

      programs.nyaa = {
        enable = true;
      };
    };
  };
}
