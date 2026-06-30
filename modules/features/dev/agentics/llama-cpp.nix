{den, ...}: {
  den.aspects.dev.agentics.llama-cpp = {
    nixos = {pkgs, ...}: {
      services.llama-cpp = {
        enable = true;
        package = pkgs.unstable.llama-cpp;
      };

      # systemd.services.llama-cpp = {
      #   environment = {
      #     XDG_CACHE_HOME = "/var/cache/llama-cpp";
      #     MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
      #   };
      # };
    };
  };
}
