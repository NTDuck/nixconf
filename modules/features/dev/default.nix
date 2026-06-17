{den, ...}: {
  den.aspects.dev = {
    includes = [
      den.aspects.agentics
      den.aspects.gits
      den.aspects.toolchains
      den.aspects.virtualizations

      den.aspects.cloudflare-warp
      den.aspects.speedtest-cli
      den.aspects.ripgrep
    ];
  };
}
