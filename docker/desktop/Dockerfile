FROM debian:trixie-slim

ARG username
ARG user_uid
ARG user_gid
ARG render_gid
ARG video_gid

RUN apt-get update && apt-get dist-upgrade -y && apt-get install --no-install-recommends -y build-essential ca-certificates curl dpkg-dev git locales sudo tini tmux vim

# Set noninteractive frontend
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Build pulseaudio with sound support over RDP
RUN apt-get install --no-install-recommends -y doxygen libpulse-dev lsb-release

RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /root/pulseaudio-module-xrdp
WORKDIR /root/pulseaudio-module-xrdp
RUN ./scripts/install_pulseaudio_sources_apt.sh
RUN ./bootstrap
RUN ./configure PULSE_DIR=/root/pulseaudio.src
RUN make
RUN sudo make install

# Install 'adw-gtk3' theme
RUN apt-get install --no-install-recommends -y sassc
RUN git clone https://github.com/lassekongo83/adw-gtk3.git /root/adw-gtk3
WORKDIR /root/adw-gtk3
RUN git checkout c2e74c9
RUN meson setup build
RUN ninja -C build install

# Cleanup
WORKDIR /
RUN rm -rf /root/adw-gtk3 /root/pulseaudio-module-xrdp

# Install remaining packages
RUN apt-get install --no-install-recommends -y dbus-x11 dmenu fastfetch feh firefox-esr fonts-firacode fonts-font-awesome fzf gsettings-desktop-schemas hsetroot i3 i3lock inetutils-ping mc mpv net-tools papirus-icon-theme pavucontrol psmisc pulseaudio-utils ranger rxvt-unicode scrot x11-xserver-utils xdg-desktop-portal-wlr xclip xorgxrdp xrdp zathura

# Make sure pulseaudio is spawning automatically
RUN sed -i -E 's/^; autospawn =.*/autospawn = yes/' /etc/pulse/client.conf

# Install localization files
RUN apt-get install --no-install-recommends -y firefox-esr-l10n-pl task-polish

# Set default keymap, language and location
COPY docker/desktop/config/debconf-config.dat /var/cache/debconf/config.dat
RUN chown root:root /var/cache/debconf/config.dat
RUN echo "pl_PL.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen
RUN dpkg-reconfigure locales -fnoninteractive

# Fix GIDs for groups to match host
RUN groupmod -g $user_gid users
RUN groupmod -g $render_gid render
RUN groupmod -g 14 sudo
RUN groupmod -g $video_gid video

RUN useradd -u $user_uid -r -g users -G render,sudo,video,xrdp -s /bin/bash -m $username
RUN echo "$username:changeme" | chpasswd

COPY docker/desktop/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["tini", "--"]
CMD ["entrypoint.sh"]
