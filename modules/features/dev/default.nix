{den, ...}: {
  den.aspects.dev = {
    includes = [
      den.aspects.agentics
      den.aspects.toolchains

      den.aspects.alejandra
      den.aspects.cloudflare-warp
      den.aspects.gh
      den.aspects.git
      den.aspects.glab
      den.aspects.speedtest-cli
    ];
  };
}
