{
  den,
  lib,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users.homeManager = {osConfig, ...}: let
    llamaCppModels = osConfig.services.llama-cpp.modelsPreset or {};
  in {
    programs.opencode.settings = {
      small_model = lib.mkDefault "llama.cpp/Qwen3-4B-Function-Calling-Pro";

      provider."llama.cpp" = {
        options.apiKey = lib.mkDefault "none";
        models =
          builtins.mapAttrs (name: preset: {
            name = lib.mkDefault name;
            limit = {
              context = lib.mkDefault (preset."ctx-size" or 32768);
              output = lib.mkDefault (preset."n-predict" or 8192);
            };
          })
          llamaCppModels;
      };
    };
  };
}
