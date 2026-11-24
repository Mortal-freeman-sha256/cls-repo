#!/bin/sh
set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/local/lib/pkgconfig
mkdir -p /src /dest_lxde /dest_sway /dest_tmux /dest_flatpak

auto_b() {
  cd /src && curl -fL "$1" -o p.tar.xz && tar -xf p.tar.xz && cd "$2"
  ./configure --prefix=/usr --sysconfdir=/etc --disable-static $3
  make -j$(nproc) && make install && make DESTDIR="$4" install
  cd /src && rm -rf "$2" p.tar.xz
}

auto_gz() {
  cd /src && curl -fL "$1" -o p.tar.gz && tar -xf p.tar.gz && cd "$2"
  ./configure --prefix=/usr --sysconfdir=/etc --disable-static $3
  make -j$(nproc) && make install && make DESTDIR="$4" install
  cd /src && rm -rf "$2" p.tar.gz
}

meson_b() {
  cd /src && curl -fL "$1" -o p.tar.xz && tar -xf p.tar.xz && cd "$2"
  meson setup build --prefix=/usr --libdir=/usr/lib --buildtype=release $3
  ninja -C build && ninja -C build install && DESTDIR="$4" ninja -C build install
  cd /src && rm -rf "$2" p.tar.xz
}

XO="www.x.org/releases/individual"
SF="downloads.sourceforge.net"
FD="gitlab.freedesktop.org"
GH="github.com"
GN="download.gnome.org/sources"

build_base_libs() {
  local D="$1"
  cd /src && curl -fL "https://github.com" -o nj.tar.gz && tar -xf nj.tar.gz && cd ninja-1.12.1 && python3 configure.py --bootstrap && cp ninja /usr/bin/ && cd /src && rm -rf ninja-1.12.1 nj.tar.gz
  cd /src && curl -fL "https://github.com" -o nj.tar.gz && tar -xf nj.tar.gz && cd ninja-1.12.1 && python3 configure.py --bootstrap && cp ninja /usr/bin/ && cd /src && rm -rf ninja-1.12.1 nj.tar.gz
  auto_gz "https://$GH/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz" "libffi-3.4.6" "" "$D"
  auto_b  "https://$GH/libexpat/libexpat/releases/download/R_2_6_4/expat-2.6.4.tar.xz" "expat-2.6.4" "--without-docbook" "$D"
  auto_b  "https://$GH/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.bz2" "pcre2-10.44" "--enable-unicode --enable-jit" "$D"
  meson_b "https://$GN/glib/2.82/glib-2.82.4.tar.xz" "glib-2.82.4" "-Dtests=false -Dman-pages=disabled" "$D"
  auto_b  "https://cairographics.org" "pixman-0.44.2" "" "$D"
  meson_b "https://freedesktop.org" "libdrm-2.4.124" "-Dudev=false -Dvalgrind=disabled" "$D"
}

case "$1" in
  lxde)
    build_base_libs /dest_lxde
    auto_b "https://$XO/util/util-macros-1.20.2.tar.xz" "util-macros-1.20.2" "" /dest_lxde
    auto_b "https://$XO/proto/xorgproto-2024.1.tar.xz" "xorgproto-2024.1" "" /dest_lxde
    auto_b "https://$XO/lib/xtrans-1.5.2.tar.xz" "xtrans-1.5.2" "" /dest_lxde
    for p in lib/libXau-1.0.11 proto/xcb-proto-1.17.0 lib/libxcb-1.17.0 lib/libX11-1.8.10 lib/libXext-1.3.6 lib/libXrender-0.9.11 lib/libXrandr-1.5.4 lib/libXfixes-6.0.1 lib/libXi-1.8.2 lib/libXcursor-1.2.3 lib/libXft-2.3.8 lib/libxkbfile-1.1.3 lib/libfontenc-1.1.8 lib/libXfont2-2.0.7; do
      auto_b "https://$XO/$p.tar.xz" "${p#*/}" "" /dest_lxde
    done
    meson_b "https://$GH/anholt/libepoxy/releases/download/1.5.10/libepoxy-1.5.10.tar.xz" "libepoxy-1.5.10" "-Dtests=false" /dest_lxde
    auto_b "https://$XO/xserver/xorg-server-21.1.14.tar.xz" "xorg-server-21.1.14" "--disable-systemd-logind --enable-kdrive=no --disable-glamor --disable-dri --disable-dri2 --disable-dri3" /dest_lxde
    auto_b "https://$XO/driver/xf86-video-fbdev-0.5.0.tar.bz2" "xf86-video-fbdev-0.5.0" "" /dest_lxde
    auto_b "https://$XO/app/xinit-1.4.2.tar.xz" "xinit-1.4.2" "" /dest_lxde
    auto_b "https://$SF/lxde/menu-cache-1.1.0.tar.xz" "menu-cache-1.1.0" "" /dest_lxde
    auto_b "https://$SF/pcmanfm/libfm-1.3.2.tar.xz" "libfm-1.3.2" "--with-gtk=2 --disable-demo" /dest_lxde
    auto_b "https://$SF/pcmanfm/pcmanfm-1.3.2.tar.xz" "pcmanfm-1.3.2" "" /dest_lxde
    auto_b "https://$SF/lxde/lxpanel-0.10.1.tar.xz" "lxpanel-0.10.1" "--enable-gtk3=no" /dest_lxde
    auto_b "https://$SF/lxde/lxsession-0.5.5.tar.xz" "lxsession-0.5.5" "--disable-buildin-polkit" /dest_lxde
    auto_b "https://$SF/lxde/lxterminal-0.4.0.tar.xz" "lxterminal-0.4.0" "" /dest_lxde
    ;;
  sway)
    build_base_libs /dest_sway
    meson_b "https://$FD/wayland/wayland/-/releases/1.23.1/downloads/wayland-1.23.1.tar.xz" "wayland-1.23.1" "-Ddocumentation=false" /dest_sway
    meson_b "https://$FD/wayland/wayland-protocols/-/releases/1.38/downloads/wayland-protocols-1.38.tar.xz" "wayland-protocols-1.38" "" /dest_sway
    meson_b "https://xkbcommon.org" "libxkbcommon-1.7.0" "-Denable-docs=false -Denable-x11=false" /dest_sway
    meson_b "https://$FD/libinput/libinput/-/archive/1.27.0/libinput-1.27.0.tar.bz2" "libinput-1.27.0" "-Dlibwacom=false -Ddebug-gui=false -Dtests=false -Ddocumentation=false" /dest_sway
    cd /src && curl -fL "https://sr.ht" -o s.tar.gz && tar -xf s.tar.gz && cd seatd-0.9.1
    meson setup build --prefix=/usr -Dlibseat-logind=disabled -Dlibseat-builtin=enabled && ninja -C build install && DESTDIR=/dest_sway ninja -C build install
    meson_b "https://$FD/wlroots/wlroots/-/releases/0.18.2/downloads/wlroots-0.18.2.tar.gz" "wlroots-0.18.2" "-Dexamples=false -Drenderers=[] -Dbackends=drm,libinput" /dest_sway
    cd /src && curl -fL "https://$GH/swaywm/sway/releases/download/1.10/sway-1.10.tar.gz" -o sw.tar.gz && tar -xf sw.tar.gz && cd sway-1.10
    meson setup build --prefix=/usr -Dzsh-completions=false -Dfish-completions=false && ninja -C build install && DESTDIR=/dest_sway ninja -C build install
    cd /src && curl -fL "https://codeberg.org" -o ft.tar.gz && tar -xf ft.tar.gz && cd foot-1.19.0
    meson setup build --prefix=/usr -Ddocs=disabled && ninja -C build install && DESTDIR=/dest_sway ninja -C build install
    ;;
  apps)
    auto_gz "https://$GH/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz" "libevent-2.1.12-stable" "" /dest_tmux
    auto_gz "https://$GH/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz" "tmux-3.5a" "" /dest_tmux
    build_base_libs /dest_flatpak
    cd /src && curl -fL "https://kernel.org" -o lc.tar.xz && tar -xf lc.tar.xz && cd libcap-2.73
    make -j$(nproc) prefix=/usr lib=lib && make prefix=/usr lib=lib install && make DESTDIR=/dest_flatpak prefix=/usr lib=lib install
    auto_b  "https://$GH/libarchive/libarchive/releases/download/v3.7.7/libarchive-3.7.7.tar.xz" "libarchive-3.7.7" "--without-xml2" /dest_flatpak
    meson_b "https://$GH/containers/bubblewrap/releases/download/v0.11.0/bubblewrap-0.11.0.tar.xz" "bubblewrap-0.11.0" "" /dest_flatpak
    meson_b "https://$GH/flatpak/flatpak/releases/download/1.15.10/flatpak-1.15.10.tar.xz" "flatpak-1.15.10" "-Dsystem_bubblewrap=/usr/bin/bwrap -Dsystemd=disabled -Dgtkdoc=disabled -Dman=disabled" /dest_flatpak
    ;;
esac
