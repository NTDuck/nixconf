{den, ...}: {
  den.aspects.dev.agentics.ollama = {
    nixos = {
      lib,
      pkgs,
      ...
    }: {
      services.ollama = {
        enable = true;
        package = pkgs.unstable.ollama;

        syncModels = true;
        loadModels = [
          "gemma4:e2b"
          "gemma4:e4b"
          "mxbai-embed-large"
          "deepseek-r1:32b"
          "hf.co/kai-os/gemma4-31b-Opus-4.6-reasoning"
        ];
      };

      systemd.services.ollama.wantedBy = lib.mkForce []; # Prevents autostart
    };
  };
}
