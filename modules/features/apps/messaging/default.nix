{den, ...}: {
  den.aspects.apps.messaging = {
    includes = [
      den.aspects.apps.messaging.discord
      # lark-cli + zalo un-included (2026-11-10 user request); aspects
      # stay declared in their files.
      den.aspects.apps.messaging.telegram
    ];
  };
}
