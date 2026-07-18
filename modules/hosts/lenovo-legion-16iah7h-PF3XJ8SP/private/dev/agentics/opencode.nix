{
  den,
  lib,
  ...
}: let
  llamaModels = import ./llama-models.expr;
in {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.provides.to-users.homeManager = {...}: {
    programs.opencode.settings = {
      model = lib.mkForce "llama.cpp/GPT-OSS [Daily Reasoning 21B total 3.6B active]";
      small_model = lib.mkForce "llama.cpp/Qwen2.5 Coder Instruct [General 1.5B total]";

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
          llamaModels);
      };
    };
  };
}
