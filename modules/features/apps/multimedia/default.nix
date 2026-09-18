{den, ...}: {
  den.aspects.apps.multimedia = {
    includes = [
      den.aspects.apps.multimedia.ffmpeg
      den.aspects.apps.multimedia.gallery-dl
      den.aspects.apps.multimedia.imv
      den.aspects.apps.multimedia.mpv
      den.aspects.apps.multimedia.obs-studio
      den.aspects.apps.multimedia.yt-dlp
      den.aspects.apps.multimedia.youtube-music
    ];
  };
}
