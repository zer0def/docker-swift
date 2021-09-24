FROM python:3.9-alpine3.14
RUN sed -i 's#/v3\.14/#/edge/#g' /etc/apk/repositories \
 && apk upgrade --no-cache \
 && pip install --no-cache-dir -U pip setuptools_rust \
 && apk add --no-cache \
    -X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
      openrc \
      memcached \
      memcached-openrc \
      rsync \
      rsync-openrc \
      rsyslog \
      rsyslog-openrc \
      attr \
      liberasurecode \
      libffi \
      libxml2 \
      libxslt \
      openssl \
      py3-tz
#      supervisor

RUN apk add --no-cache \
    -X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
    -t .builddeps \
      build-base \
      cargo \
      git \
      liberasurecode-dev \
      libffi-dev \
      libxml2-dev \
      libxslt-dev \
      openssl-dev \
      rust \
 && git clone --branch 3.11.1 --single-branch --depth 1 https://github.com/openstack/python-swiftclient.git /usr/local/src/python-swiftclient \
 && cd /usr/local/src/python-swiftclient && python3 setup.py develop \
 && git clone --branch 2.27.0 --single-branch --depth 1 https://github.com/openstack/swift.git /usr/local/src/swift \
 && cd /usr/local/src/swift && python3 setup.py develop \
 && rm -rf /root/.cache /root/.cargo \
 && apk del .builddeps

COPY ./swift /etc/swift
COPY ./misc/rsyncd.conf /etc/
COPY ./bin /swift/bin
COPY ./rsyslog.d/10-swift.conf /etc/rsyslog.d/10-swift.conf
#COPY ./misc/supervisord.conf /etc/supervisord.conf

RUN /usr/sbin/adduser -D swift \
 && sed -i 's/SLEEP_BETWEEN_AUDITS = 30/SLEEP_BETWEEN_AUDITS = 86400/' /usr/local/src/swift/swift/obj/auditor.py \
 && sed -i 's/\$PrivDropToGroup syslog/\$PrivDropToGroup adm/' /etc/rsyslog.conf \
 && sed -i '/imklog/s/^/#/' /etc/rsyslog.conf \
 && mkdir -p /var/log/swift/hourly; chgrp -R adm /var/log/swift; chmod -R g+w /var/log/swift \
 && mkdir -p /swift/nodes/1 /srv/1/node/sdb1 /var/cache/swift \
 && ln -s /swift/nodes/1 /srv/1 \
 && chown -R swift:swift /swift/nodes /etc/swift /srv/1 /var/cache/swift
# && mkdir /var/log/supervisor/

EXPOSE 8080
CMD ["/bin/sh", "/swift/bin/launch.sh"]
