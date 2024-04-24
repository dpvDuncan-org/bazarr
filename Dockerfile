# syntax=docker/dockerfile:1

FROM alpine AS builder

ARG TARGETARCH

COPY scripts/start.sh /

RUN apk -U --no-cache upgrade
RUN apk add --no-cache --virtual=.build-dependencies py3-pip python3-dev build-base
RUN apk add --no-cache ca-certificates curl ffmpeg python3 libffi py3-lxml py3-libxml2 py3-numpy py3-setuptools
COPY unrar.tar.gz /tmp/unrar.tar.gz
RUN tar -xzf /tmp/unrar.tar.gz -C /tmp
WORKDIR /tmp/unrar
RUN make && make install
RUN mkdir -p /opt/bazarr /config
COPY bazarr.zip /tmp/bazarr.zip
RUN busybox unzip /tmp/bazarr.zip -d /opt/bazarr
RUN rm -rf /tmp/bazarr.zip
RUN rm -rf /opt/bazarr/bin
WORKDIR /opt/bazarr
RUN python -m venv venv
RUN . venv/bin/activate && pip install --no-cache-dir wheel
RUN . venv/bin/activate && pip install --no-cache-dir -r /opt/bazarr/requirements.txt
RUN apk del --purge .build-dependencies
RUN chmod -R 777 /opt/bazarr /start.sh

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

FROM scratch

ARG BAZARR_RELEASE

ENV PUID=0
ENV PGID=0
ENV BAZARR_RELEASE=${BAZARR_RELEASE}
ENV TZ=Europe/Paris

COPY --from=builder / /
WORKDIR /opt/bazarr
# ports and volumes
EXPOSE 6767
VOLUME /config

CMD ["/start.sh"]
