{ pkgs ? import <nixpkgs> {} }:

let
  airllm = pkgs.python3Packages.buildPythonPackage rec {
    pname = "airllm";
    version = "2.11.0";
    pyproject = true;

    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0vc5f79jw7cxbf1wmwcgqqhcxx9bcjl1yabjgrkcwr0xw1yx3yv2";
    };

    build-system = with pkgs.python3Packages; [ setuptools ];
    nativeBuildInputs = with pkgs.python3Packages; [ pip ];

    postPatch = ''
      sed -i 's/subprocess.check_call.*//' setup.py
    '';
    
    dependencies = with pkgs.python3Packages; [
      tqdm
      torch
      transformers
      accelerate
      safetensors
      optimum
      huggingface-hub
      scipy
    ];

    doCheck = false;
  };

  pythonWithAirllm = pkgs.python3.withPackages (ps: [ airllm ]);
in pkgs.writeScriptBin "airllm-cli" ''
  #!${pythonWithAirllm}/bin/python
  import sys
  from airllm import AutoModel
''
