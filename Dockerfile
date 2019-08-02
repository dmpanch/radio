FROM alpine
MAINTAINER dmpanch

ENV MPD_VERSION 0.21.10-r0
ENV MPC_VERSION 0.32-r0
ENV PYTHON_VERSION 3.7.3-r0

# https://docs.docker.com/engine/reference/builder/#arg

RUN apk -q update \
    && apk -q --no-progress add mpd="$MPD_VERSION" \
    && apk -q --no-progress add mpc="$MPC_VERSION" \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /var/lib/mpd/music \
    && mkdir -p /var/lib/mpd/playlists \
    && mkdir -p /var/lib/mpd/database \
    && mkdir -p /var/log/mpd/mpd.log \
    && chown -R mpd:audio /var/lib/mpd \
    && chown -R mpd:audio /var/log/mpd/mpd.log \
    && chmod -R 755 /var/lib/mpd

# Declare a music , playlists and database volume (state, tag_cache and sticker.sql)
VOLUME ["/var/lib/mpd"]

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

COPY mpd.conf /etc/mpd.conf
COPY config.py /mpddj/config.py
COPY start.sh /start.sh

RUN chown -R root:root /mpddj
RUN chmod -R 755 /mpddj
RUN chmod -R 755 start.sh

RUN touch /var/lib/mpd/database/tag_cache \
    && chown -R mpd:audio /var/lib/mpd/database/tag_cache

# Entry point for mpc update and stuff
EXPOSE 6600
EXPOSE 8001

CMD ["/start.sh"]