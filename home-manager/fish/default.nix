pkgs: {
  home.packages = [ pkgs.starship ];
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./interactive.fish;
    shellAbbrs = rec {
      ll = "ls -l";
      la = "ls -A";
      rm = "rm -i";
      mv = "mv -n";
      r = "rsync --archive --verbose --human-readable --progress --one-file-system --ignore-existing";
      gs = "git status";
      gl = "git log";
      glo = "git log --oneline";
      gf = "log --pretty=format:'%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(cyan)%cr%C(reset) %s %C(green)%d%C(reset)' --graph";
      sc = "systemctl";
      scu = "systemctl --user";
      jc = "journalctl";
      jcu = "journalctl --user";
      config = "cd ~/nixos-config && nvim";
      d = "dua --stay-on-filesystem interactive";
      new-ssh-key = "ssh-keygen -t ed25519 -C 'stel@stel.codes'";
      date-iso = "date -u +%Y-%m-%dT%H:%M:%SZ"; # ISO 8601 date format with UTC timezone
      t = "tmux attach -t config; or tmux";
      n = "nnn -eauUA";
      beep = "timeout -s KILL 0.15 speaker-test --frequency 400 --test sin";
      dl-base = "yt-dlp --embed-metadata --embed-thumbnail --progress";
      dl-video = "${dl-base} --embed-subs --sub-langs 'en' --embed-chapters --sponsorblock-mark 'default' --sponsorblock-remove 'sponsor,selfpromo,outro' --remux-video 'mkv'";
      dl-video-best = "${dl-video} --format best";
      dl-video-1080 = "${dl-video} --format 'worstvideo[height=1080]+bestaudio / best[height<=1080]'";
      dl-video-1080-playlist = "${dl-video-1080} --output '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'";
      dl-music = "${dl-base} --format 'bestaudio[ext=ogg] / bestaudio[ext=mp3]' --output '%(album_artist,artist|unknown artist)s/%(album,track|unknown album)s/%(track_number|0)s %(track,id,epoch)s.%(ext)s'";
      dl-music-best = "${dl-music} --format 'bestaudio[ext=flac] / bestaudio[ext=ogg] / bestaudio[ext=mp3]'";
      dl-music-yt = "${dl-base} --format 'bestaudio' --extract-audio --audio-format opus";
      noansi = "sed \"s,\\x1B\\[[0-9;]*[a-zA-Z],,g\"";
      loggy = "${noansi} | tee ~/tmp/$(date +%F-%T)-log.txt";
    };
    functions = {
      nnn-rsync = builtins.readFile ./nnn-rsync.fish;
    };
  };
}
