#!/bin/sh
mkdir -p /var/run/swift; chown -R swift:swift /var/run/swift
/usr/sbin/service rsyslog start
/usr/sbin/service rsync start
/usr/sbin/service memcached start

# set up storage
su swift /swift/bin/remakerings
# either fold these two as fg under supervisor or don't use it at all
su swift -c "/usr/local/bin/swift-init main start"
su swift -c "/usr/local/bin/swift-init rest start"
#/usr/local/bin/supervisord -n -c /etc/supervisord.conf
while true; do sleep infinity; done
