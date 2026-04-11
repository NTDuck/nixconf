{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;

    syncModels = true;
    loadModels = [
      "gemma4:e2b"
      "gemma4:e4b"
    ];
  };
}
