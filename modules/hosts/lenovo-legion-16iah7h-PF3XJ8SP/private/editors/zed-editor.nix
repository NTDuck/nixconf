{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      programs.zed-editor.userSettings = {
        agent = {
          default_model = {
            provider = "openai";
            model = "bonsai2";
            api_url = "http://127.0.0.1:8080/v1";
          };
          dock = "right";
          favourite_models = [];
          model_parameters = [];
        };
      };
    };
  };
}
