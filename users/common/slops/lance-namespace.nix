{
  lib,
  pkgs,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "lance-namespace";
  version = "0.6.1";

  src = pkgs.fetchurl {
    url = "https://files.pythonhosted.org/packages/b9/a3/9a65c2b5311b3531b4334a65135ace45c75468d601b5a59f92842b15a63c/lance_namespace-0.6.1.tar.gz";
    sha256 = "f0deea442bd3f1056a8e2fed056ae2778e3356517ec2e680db049058b824d131";
  };

  propagatedBuildInputs = [];

  meta = with lib; {
    description = "Lance Namespace interface and plugin registry";
    homepage = "https://github.com/lancedb/lancedb";
    license = licenses.asl20;
    maintainers = [ maintainers.ayin ]; # placeholder
  };
}
