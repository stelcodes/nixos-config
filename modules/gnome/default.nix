{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.gnome ];
  environment.etc."gnome/.xinitrc" = ''
    export XDG_SESSION_TYPE=x11
    export GDK_BACKEND=x11
    exec gnome-session
  '';
}
