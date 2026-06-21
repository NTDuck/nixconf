# {den, ...}: {
#   den.aspects.airllm = {
#     nixos = {pkgs, ...}: let
#       airllm = pkgs.python3Packages.buildPythonPackage rec {
#         pname = "airllm";
#         version = "2.11.0";
#         pyproject = true;
#         src = pkgs.python3Packages.fetchPypi {
#           inherit pname version;
#           sha256 = "0vc5f79jw7cxbf1wmwcgqqhcxx9bcjl1yabjgrkcwr0xw1yx3yv2";
#         };
#         build-system = with pkgs.python3Packages; [ setuptools ];
#         nativeBuildInputs = with pkgs.python3Packages; [ pip ];
#         postPatch = ''
#           sed -i 's/subprocess.check_call.*//' setup.py
#         '';
#         dependencies = with pkgs.python3Packages; [
#           tqdm
#           torch
#           transformers
#           accelerate
#           safetensors
#           optimum
#           huggingface-hub
#           scipy
#         ];
#         doCheck = false;
#       };
#       pythonWithAirllm = pkgs.python3.withPackages (ps: [ airllm ]);
#       airllm-cli = pkgs.writeScriptBin "airllm-cli" ''
#         #!${pythonWithAirllm}/bin/python
#         import sys
#         from airllm import AutoModel
#         MAX_LENGTH = 1024
#         if len(sys.argv) < 2:
#             print("Usage: airllm-cli <huggingface_model_id>")
#             sys.exit(1)
#         model_id = sys.argv[1]
#         print(f"Loading {model_id} via AirLLM...")
#         try:
#             model = AutoModel.from_pretrained(model_id)
#         except Exception as e:
#             print(f"Failed to load model: {e}")
#             sys.exit(1)
#         print("Model loaded! Type 'exit' or 'quit' to stop.")
#         while True:
#             try:
#                 prompt = input("Prompt> ")
#             except EOFError:
#                 break
#             if prompt.strip().lower() in ['exit', 'quit']:
#                 break
#             if not prompt.strip():
#                 continue
#             input_tokens = model.tokenizer([prompt],
#                 return_tensors="pt",
#                 return_attention_mask=False,
#                 truncation=True,
#                 max_length=MAX_LENGTH,
#                 padding=False)
#             generation_output = model.generate(
#                 input_tokens['input_ids'].cuda(),
#                 max_new_tokens=1024,
#                 use_cache=True,
#                 return_dict_in_generate=True)
#             output = model.tokenizer.decode(generation_output.sequences[0], skip_special_tokens=True)
#             print("Response:")
#             print(output)
#       '';
#     in {
#       environment.systemPackages = [ airllm-cli ];
#     };
#   };
# }
{}
