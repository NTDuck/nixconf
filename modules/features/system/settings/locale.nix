{den, ...}: {
  den.aspects.system-locale = {
    nixos = {
      time.timeZone = "Asia/Ho_Chi_Minh";
      i18n.defaultLocale = "en_US.UTF-8";
    };
  };
}
