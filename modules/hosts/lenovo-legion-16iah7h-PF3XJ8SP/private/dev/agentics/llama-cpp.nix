{den, ...}: let
  llamaModels = import ./llama-models.expr;
in {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.nixos = {
    pkgs,
    lib,
    ...
  }: {
    services.llama-cpp = {
      package = lib.mkForce (pkgs.unstable.llama-cpp.override {
        cudaSupport = true;
      });

      modelsPreset = llamaModels;
    };

    # Gemma downloads still need HF_TOKEN here after accepting Google's terms,
    # but a missing local secret must not make system activation fail.
    systemd.services.llama-cpp.serviceConfig.EnvironmentFile = "-/etc/llama-cpp/huggingface.env";
  };
}
