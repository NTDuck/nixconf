{den, ...}: {
  den.aspects.dev.cloud = {
    includes = [
      den.aspects.dev.cloud.google-cloud-sdk
      den.aspects.dev.cloud.oracle-cloud-infrastructure
    ];
  };
}
