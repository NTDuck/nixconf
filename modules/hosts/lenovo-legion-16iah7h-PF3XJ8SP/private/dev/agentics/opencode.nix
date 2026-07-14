{
  den,
  lib,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users.homeManager = {osConfig, ...}: let
    llamaCppModels = osConfig.services.llama-cpp.modelsPreset or {};
  in {
    programs.opencode.settings = {
      small_model = lib.mkForce "llama.cpp/Qwen2.5 Coder [3B]";

      provider."llama.cpp" = {
        options.apiKey = lib.mkDefault "none";
        models = builtins.listToAttrs (lib.mapAttrsToList (name: preset: let
            modelName = preset.alias or name;
          in {
            name = modelName;
            value = {
              name = lib.mkDefault modelName;
              limit = {
                context = lib.mkDefault (preset."ctx-size" or 32768);
                output = lib.mkDefault (preset."n-predict" or 8192);
              };
            };
          })
          llamaCppModels);
      };
    };
  };
}
