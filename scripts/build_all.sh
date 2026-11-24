#!/bin/sh
set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/share/pkgconfig
mkdir -p /src /dest_lxde /dest_sway /dest_tmux /dest_flatpak

auto_b() {
  cd /src && curl -fL "$1" -o p.tar.xz && tar -xf p.tar.xz && cd "$2"
  ./configure --prefix=/usr --sysconfdir=/etc --disable-static $3
  make -j$(nproc) && make install && make DESTDIR="$4" install
  cd /src && rm -rf "$2" p.tar.xz
}

meson_b() {
  cd /src && curl -fL "$1" -o p.tar.gz && tar -xf p.tar.gz && cd "$2"
  meson setup build --prefix=/usr --buildtype=release $3
  ninja -C build && ninja -C build install && DESTDIR="$4" ninja -C build install
  cd /src && rm -rf "$2" p.tar.gz
}

XO="www.x.org/releases/individual"
SF="downloads.sourceforge.net"
FD="gitlab.freedesktop.org"
GH="github.com"

case "$1" in
  lxde)
    for p in proto/xorgproto-2024.1 lib/libXau-1.0.11 proto/xcb-proto-1.17.0 lib/libxcb-1.17.0 lib/libX11-1.8.10 lib/libXext-1.3.6 lib/libXrender-0.9.11 lib/libXrandr-1.5.4 lib/libXfixes-6.0.1 lib/libXi-1.8.2 lib/libXcursor-1.2.3 lib/libXft-2.3.8; do
      auto_b "https://$XO/$p.tar.xz" "${p#*/}" "" /dest_lxde
    done
    auto_b "https://$XO/xserver/xorg-server-21.1.14.tar.xz" "xorg-server-21.1.14" "--disable-systemd-logind --enable-kdrive=no" /dest_lxde
    auto_b "https://$XO/driver/xf86-input-libinput-1.5.0.tar.xz" "xf86-input-libinput-1.5.0" "" /dest_lxde
    auto_b "https://$XO/driver/xf86-video-amdgpu-23.0.0.tar.xz" "xf86-video-amdgpu-23.0.0" "" /dest_lxde
    auto_b "https://$XO/app/xinit-1.4.2.tar.xz" "xinit-1.4.2" "" /dest_lxde
    auto_b "https://$SF/lxde/menu-cache-1.1.0.tar.xz" "menu-cache-1.1.0" "" /dest_lxde
    auto_b "https://$SF/pcmanfm/libfm-1.3.2.tar.xz" "libfm-1.3.2" "--with-gtk=2 --disable-demo" /dest_lxde
    auto_b "https://$SF/pcmanfm/pcmanfm-1.3.2.tar.xz" "pcmanfm-1.3.2" "" /dest_lxde
    auto_b "https://$SF/lxde/lxpanel-0.10.1.tar.xz" "lxpanel-0.10.1" "--enable-gtk3=no" /dest_lxde
    auto_b "https://$SF/lxde/lxsession-0.5.5.tar.xz" "lxsession-0.5.5" "--disable-buildin-polkit" /dest_lxde
    auto_b "https://$SF/lxde/lxterminal-0.4.0.tar.xz" "lxterminal-0.4.0" "" /dest_lxde
    ;;
  sway)
    meson_b "https://$FD/wayland/wayland/-/releases/1.23.1/downloads/wayland-1.23.1.tar.xz" "wayland-1.23.1" "-Ddocumentation=false" /dest_sway
    meson_b "https://$FD/wayland/wayland-protocols/-/releases/1.38/downloads/wayland-protocols-1.38.tar.xz" "wayland-protocols-1.38" "" /dest_sway
    meson_b "https://sr.ht" "seatd-0.9.1" "-Dlibseat-logind=disabled -Dlibseat-builtin=enabled" /dest_sway
    meson_b "https://$FD/wlroots/wlroots/-/releases/0.18.2/downloads/wlroots-0.18.2.tar.gz" "wlroots-0.18.2" "-Dexamples=false" /dest_sway
    meson_b "https://$GH/swaywm/sway/releases/download/1.10/sway-1.10.tar.gz" "sway-1.10" "-Dzsh-completions=false -Dfish-completions=false" /dest_sway
    meson_b "https://codeberg.org" "foot-1.19.0" "-Ddocs=disabled" /dest_sway
    ;;
  apps)
    cd /src && curl -fL "https://$GH/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz" -o le.tar.gz
    tar -xf le.tar.gz && cd libevent-2.1.12-stable && ./configure --prefix=/usr --disable-static && make -j$(nproc) && make install && make DESTDIR=/dest_tmux install
    cd /src && curl -fL "https://$GH/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz" -o tm.tar.gz
    tar -xf tm.tar.gz && cd tmux-3.5a && ./configure --prefix=/usr && make -j$(nproc) && make install && make DESTDIR=/dest_tmux install
    meson_b "https://$GH/containers/bubblewrap/releases/download/v0.11.0/bubblewrap-0.11.0.tar.xz" "bubblewrap-0.11.0" "" /dest_flatpak
    meson_b "https://$GH/flatpak/flatpak/releases/download/1.15.10/flatpak-1.15.10.tar.xz" "flatpak-1.15.10" "-Dsystem_bubblewrap=/usr/bin/bwrap -Dsystemd=disabled -Dgtkdoc=disabled -Dman=disabled" /dest_flatpak
    ;;
esac
