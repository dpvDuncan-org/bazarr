# syntax=docker/dockerfile:1
ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}alpine

ARG bazarr_url
ARG BAZARR_RELEASE

ENV PUID=0
ENV PGID=0
ENV BAZARR_RELEASE=${BAZARR_RELEASE}
ENV TZ=Europe/Paris

COPY scripts/start.sh /

RUN apk -U --no-cache upgrade
RUN apk add --no-cache --virtual=.build-dependencies py3-pip python3-dev build-base
RUN apk add --no-cache ca-certificates curl ffmpeg python3 libffi py3-lxml py3-libxml2 py3-numpy py3-setuptools
RUN curl -o - -L https://www.rarlab.com/rar/unrarsrc-6.1.7.tar.gz | tar xz -C /tmp
WORKDIR /tmp/unrar
RUN make && make install
RUN mkdir -p /opt/bazarr /config
# RUN curl -o - -L "${bazarr_url}" | tar xz -C /opt/bazarr --strip-components=1
RUN curl -o bazarr.zip -L "${bazarr_url}"
RUN busybox unzip bazarr.zip -d /opt/bazarr
RUN rm -rf bazarr.zip
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
WORKDIR /opt/bazarr

CMD ["/start.sh"]
