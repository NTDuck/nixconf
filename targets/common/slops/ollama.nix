{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;

    syncModels = true;
    loadModels = [
      "gemma-4:e2b"
      "gemma-4:e4b"
    ];
  };
}
