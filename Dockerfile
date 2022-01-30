# syntax=docker/dockerfile:1
ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}alpine

ARG bazarr_url
ARG BAZARR_RELEASE

ENV PUID=0
ENV PGID=0
ENV BAZARR_RELEASE=${BAZARR_RELEASE}

COPY scripts/start.sh /

RUN apk -U --no-cache upgrade
RUN apk add --no-cache --virtual=.build-dependencies gcc py3-pip python3-dev musl-dev
RUN apk add --no-cache ca-certificates curl ffmpeg python3 libffi py3-lxml py3-libxml2 py3-numpy py3-setuptools
RUN mkdir -p /opt/bazarr /config
RUN curl -o - -L "${bazarr_url}" | tar xz -C /opt/bazarr --strip-components=1
RUN rm -rf /opt/bazarr/bin
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir -r /opt/bazarr/requirements.txt
RUN pip3 install --upgrade setuptools
RUN apk del --purge .build-dependencies
RUN chmod -R 777 /opt/bazarr /start.sh

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# ports and volumes
EXPOSE 6767
VOLUME /config

CMD ["/start.sh"]
