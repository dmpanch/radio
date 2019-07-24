FROM alpine
MAINTAINER dmpanch

ENV MPD_VERSION 0.21.10-r0
ENV MPC_VERSION 0.32-r0
ENV ICECAST_VERSION 2.4.4-r1
ENV PYTHON_VERSION 3.7.3-r0

# https://docs.docker.com/engine/reference/builder/#arg

ARG user=root
ARG group=root

RUN apk -q update \
    && apk -q --no-progress add mpd="$MPD_VERSION" \
    && apk -q --no-progress add mpc="$MPC_VERSION" \
    && apk -q --no-progress add icecast="$ICECAST_VERSION" \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /var/lib/mpd/music \
    && mkdir -p /var/lib/mpd/playlists \
    && mkdir -p /var/lib/mpd/database \
    && mkdir -p /var/log/mpd/mpd.log \
    && chown -R ${user}:${group} /var/lib/mpd \
    && chown -R ${user}:${group} /var/log/mpd/mpd.log \
    && chmod -R 755 /var/lib/mpd

# Declare a music , playlists and database volume (state, tag_cache and sticker.sql)
VOLUME ["/var/lib/mpd/music", "/var/lib/mpd/playlists", "/var/lib/mpd/database"]

# mpddj here

RUN apk -q update \
    && apk -q --no-progress add python3-dev \
    && apk -q --no-progress add curl \
    && pip3 install --upgrade pip setuptools \
    && apk -q --no-progress add py3-gobject3

RUN pip3 install python-musicpd

RUN apk update && \
    apk add --no-cache bash git openssh alpine-sdk libffi

RUN apk add --no-cache libffi-dev ca-certificates openssl openssl-dev

RUN git clone https://github.com/python-telegram-bot/python-telegram-bot --recursive \
    && cd python-telegram-bot \
    && python3 setup.py install \
    && cd ..

RUN git clone https://github.com/dmpanch/mpddj.git

COPY icecast.xml /usr/share/icecast/icecast.xml
COPY mpd.conf /etc/mpd.conf
COPY config.py /mpddj/config.py
COPY start.sh /start.sh

RUN addgroup -S icecast2 && adduser -S icecast2 -G icecast2

RUN mkdir -p /var/log/icecast \
    && chown -R icecast2 /usr/share/icecast \
    && chown -R icecast2 /var/log/icecast

RUN chown -R ${user}:${group} /mpddj
RUN chmod -R 755 /mpddj
RUN chmod -R 755 start.sh

# Entry point for mpc update and stuff
EXPOSE 6600
EXPOSE 8000

#CMD icecast -c /usr/share/icecast/icecast.xml && python3 /mpddj/main.py && mpd --stdout --no-daemon

CMD ["/start.sh"]