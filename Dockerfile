FROM jlesage/baseimage-gui:ubuntu-22.04-v4

# Do most installs at once to minimise docker image layers
# Install software-properties-common to allow 'add-apt-repository'
# Install mediaelch repository, then mediaelch
# Install ffmpeg for mediaelch to create screenshots
# Do progressive cleanups to shrink layers
# Create user for mediaelch
# Generate docker-entrypoint.sh & startapp.sh
RUN apt-get update -y && \
    apt-get -y --no-install-recommends install software-properties-common && \
    add-apt-repository ppa:mediaelch/mediaelch-stable && \
    apt-get update -y && \
    apt-get -y --no-install-recommends install \
     mediaelch \
     ffmpeg \
     locales && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    adduser --disabled-password --gecos ""  mediaelch && \
    touch /usr/local/bin/docker-entrypoint.sh && \
    echo '#!/bin/sh' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'set -e' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'PUID=${PUID:-20000}' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'PGID=${PGID:-20000}' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'groupmod -o -g "$PGID" mediaelch' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'usermod -o -u "$PUID" mediaelch' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'chown mediaelch:mediaelch /home/mediaelch' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'chown mediaelch:mediaelch /home/mediaelch/.*' >> /usr/local/bin/docker-entrypoint.sh && \
    echo 'exec "$@"' >> /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    echo 'export LC_ALL=en_US.UTF-8' >> /home/mediaelch/.profile && \
    echo 'export LANG=en_US.UTF-8' >> /home/mediaelch/.profile && \
    echo 'export LANGUAGE=en_US.UTF-8' >> /home/mediaelch/.profile && \
    echo 'export LC_ALL=en_US.UTF-8' >> /home/mediaelch/.bashrc && \
    echo 'export LANG=en_US.UTF-8' >> /home/mediaelch/.bashrc && \
    echo 'export LANGUAGE=en_US.UTF-8' >> /home/mediaelch/.bashrc && \
    touch /startapp.sh && \
    echo '#!/bin/sh' >> /startapp.sh && \
    echo 'exec env HOME=/home/mediaelch /usr/bin/MediaElch' >> /startapp.sh && \
    chmod +x /startapp.sh && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*
    
# Define variables.
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    APP_NAME="MediaElch" \
    DISPLAY_WIDTH="1600" \
    DISPLAY_HEIGHT="900"
VOLUME ["/media/movies"]
VOLUME ["/media/tv"]
VOLUME ["/home/mediaelch/.config/kvibes"]
# VOLUME ["/config/xdg/config/kvibes"]
# VOLUME ["/.config/kvibes/MediaElch.conf"]
