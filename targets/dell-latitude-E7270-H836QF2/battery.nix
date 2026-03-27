{ ... }:

{
  services.undervolt = {
    enable = true;
    coreOffset = -50;
    gpuOffset = -50;
    uncoreOffset = -50;
    analogioOffset = -50;
  };

  boot.kernelParams = [ "msr.allow_writes=on" ]; # Allow writing to CPU registers
}
