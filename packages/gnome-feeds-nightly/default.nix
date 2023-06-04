{ lib
, callPackage

, fetchFromGitLab

, appstream
, gobject-introspection
, meson
, ninja
, pkg-config
, wrapGAppsHook

, glib
, glib-networking
, python3

, syndication-domination ? callPackage ./syndication-domination.nix { }
, libadwaita
, gtk4
, webkitgtk_6_0
, blueprint-compiler
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gnome-feeds";
  version = "2.2.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "gfeeds";
    rev = "c196af0a45fa97ef2555f9504c61ac0b76e63147";
    sha256 = "sha256-XKwRFjz4ocH01mj8KshLGmGxbm/uvDiyYRf65KL0UFw=";
  };

  format = "other";

  nativeBuildInputs = [
    appstream
    glib # for glib-compile-schemas
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook
    blueprint-compiler
  ];

  buildInputs = [
    glib
    glib-networking
    gtk4
    libadwaita
    webkitgtk_6_0
  ];

  propagatedBuildInputs = with python3.pkgs; [
    beautifulsoup4
    python-dateutil
    html5lib
    lxml
    pillow
    pygments
    pygobject3
    readability-lxml
    pytz
    requests
    python-magic
    syndication-domination
    humanize
  ];

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "An RSS/Atom feed reader for GNOME";
    homepage = "https://gitlab.gnome.org/World/gfeeds";
    license = licenses.gpl3Plus;
    maintainers = [
      maintainers.pbogdan
    ];
    platforms = platforms.linux;
  };
}
