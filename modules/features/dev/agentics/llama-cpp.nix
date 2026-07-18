{den, ...}: {
  den.aspects.dev.agentics.llama-cpp = {
    nixos = {pkgs, ...}: {
      services.llama-cpp = {
        enable = true;
        package = pkgs.unstable.llama-cpp;
      };

      systemd.services.llama-cpp.environment = {
        HF_HOME = "/var/cache/llama-cpp/huggingface";
        HF_HUB_CACHE = "/var/cache/llama-cpp/huggingface/hub";
        XDG_CACHE_HOME = "/var/cache/llama-cpp";
      };
    };
  };
}
