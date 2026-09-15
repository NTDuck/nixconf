{den, ...}: {
  den.aspects.dev = {
    includes = [
      den.aspects.dev.agentics
      den.aspects.dev.envs
      den.aspects.dev.gits
      den.aspects.dev.toolchains

      den.aspects.dev.cloud.google-cloud-sdk
      den.aspects.dev.cloud.oracle-cloud-infrastructure
      den.aspects.dev.api.dbeaver
      den.aspects.dev.api.harlequin
      den.aspects.dev.api.postman
      den.aspects.dev.iac.terraform
    ];
  };
}
