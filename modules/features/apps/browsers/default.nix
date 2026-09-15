{den, ...}: {
  den.aspects.apps.browsers = {
    includes = [
      den.aspects.apps.browsers.chromium
      den.aspects.apps.browsers.firefox
      den.aspects.apps.browsers.zen-browser
    ];
  };
}
