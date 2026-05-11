{
  lib,
  pkgs,
  python3Packages,
  lance-namespace,
}:
python3Packages.buildPythonPackage rec {
  pname = "lancedb";
  version = "0.30.2";

  src = pkgs.fetchurl {
    url = "https://files.pythonhosted.org/packages/f3/f7/7835154034c56e2a8c2415d167196ad3a94a2f8c5f9f8b4d8c8b8c8b8c8c/lancedb-0.30.2.tar.gz";
    sha256 = "0d7b1f3c5b5b4e3f3b4b5e7a9b1c0c1b0b1b0b1b0b1b0b1b0b1b0b1b0b1b0b1b"; # placeholder
  };

  buildInputs = [
    python3Packages.maturin
  ];

  propagatedBuildInputs = [
    python3Packages.deprecation
    python3Packages.numpy
    python3Packages.overrides
    python3Packages.packaging
    python3Packages.pyarrow
    python3Packages.pydantic
    python3Packages.tqdm
    lance-namespace
  ];

  meta = with lib; {
    description = "A lightweight, serverless vector database that's easy to embed in your application.";
    homepage = "https://github.com/lancedb/lancedb";
    license = licenses.asl20;
    maintainers = [maintainers.ayin]; # placeholder
  };
}
