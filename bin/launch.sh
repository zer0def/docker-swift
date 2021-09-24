#!/bin/sh
mkdir -p /run/openrc; touch /run/openrc/softlevel; rc-status &>/dev/null
mkdir -p /var/run/swift; chown -R swift:swift /var/run/swift
service rsyslog start
service rsyncd start
service memcached start

# set up storage
su swift /swift/bin/remakerings
# either fold these two as fg under supervisor or don't use it at all
su swift -c "/usr/local/bin/swift-init main start"
su swift -c "/usr/local/bin/swift-init rest start"
#supervisord -n -c /etc/supervisord.conf
while true; do sleep infinity; done
