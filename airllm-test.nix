{ pkgs ? import <nixpkgs> {} }:

let
  airllm = pkgs.python3Packages.buildPythonPackage rec {
    pname = "airllm";
    version = "2.11.0";

    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0vc5f79jw7cxbf1wmwcgqqhcxx9bcjl1yabjgrkcwr0xw1yx3yv2";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
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
in pkgs.python3.withPackages (ps: [ airllm ])
